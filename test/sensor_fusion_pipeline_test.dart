import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';
import 'package:vkr_regatta/src/features/sensor_bridge/domain/sensor_bridge_repository.dart';
import 'package:vkr_regatta/src/features/sensor_fusion/application/process_imu_chunk_use_case.dart';
import 'package:vkr_regatta/src/features/sensor_fusion/domain/fusion_session_state.dart';
import 'package:vkr_regatta/src/features/tracking/application/tracking_sample_ingestion_service.dart';
import 'package:vkr_regatta/src/features/tracking/domain/derived_metric_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/imu_chunk_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_health.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_point_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_repository.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_session_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_session_repository.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_job_entity.dart';

void main() {
  group('ProcessImuChunkUseCase', () {
    test(
      'produces stable heading, heel and zero turn rate for level chunk',
      () {
        const useCase = ProcessImuChunkUseCase();
        final chunk = ImuChunkEntity(
          sessionId: 1,
          capturedAtUtc: DateTime.utc(2026, 4, 29, 15, 0, 0),
          chunkStartMonotonicNs: 0,
          sampleCount: 18,
          samplingHz: 50,
          payload: _encodeSensorEvents(<_EncodedEvent>[
            ..._stationaryEvents(baseTimestampNs: 1_000_000_000),
            ..._stationaryEvents(baseTimestampNs: 1_200_000_000),
          ]),
          payloadFormat: 'imu-sensor-event-le-v1',
        );

        final result = useCase.execute(
          chunk: chunk,
          currentState: const FusionSessionState(
            hasCalibration: true,
            accelerometerBias: <double>[0, 0, 0],
            gyroscopeBias: <double>[0, 0, 0],
            magnetometerBias: <double>[0, 0, 0],
          ),
          recentGpsPoints: <TrackingPointEntity>[
            TrackingPointEntity(
              timestampUtc: DateTime.utc(2026, 4, 29, 15, 0, 0),
              longitude: 30.0,
              latitude: 60.0,
              speedMetersPerSecond: 0.5,
            ),
          ],
        );

        expect(_metricValue(result.metrics, 'roll_deg').abs(), lessThan(2.0));
        expect(_metricValue(result.metrics, 'pitch_deg').abs(), lessThan(2.0));
        expect(_metricValue(result.metrics, 'heading_deg'), closeTo(0.0, 5.0));
        expect(
          _metricValue(result.metrics, 'turn_rate_deg_s').abs(),
          lessThan(1.0),
        );
        expect(_metricValue(result.metrics, 'quality_calibration_missing'), 0);
        expect(_metricValue(result.metrics, 'quality_magnetic_instability'), 0);
      },
    );

    test('calibration suppresses static gyro bias on later chunk', () {
      const useCase = ProcessImuChunkUseCase();
      final biasedStaticEvents = <_EncodedEvent>[
        ..._stationaryEvents(baseTimestampNs: 2_000_000_000, gyroZ: 0.12),
        ..._stationaryEvents(baseTimestampNs: 2_200_000_000, gyroZ: 0.12),
        ..._stationaryEvents(baseTimestampNs: 2_400_000_000, gyroZ: 0.12),
        ..._stationaryEvents(baseTimestampNs: 2_600_000_000, gyroZ: 0.12),
      ];
      final first = useCase.execute(
        chunk: ImuChunkEntity(
          sessionId: 4,
          capturedAtUtc: DateTime.utc(2026, 4, 29, 16, 0, 0),
          chunkStartMonotonicNs: 0,
          sampleCount: biasedStaticEvents.length,
          samplingHz: 50,
          payload: _encodeSensorEvents(biasedStaticEvents),
          payloadFormat: 'imu-sensor-event-le-v1',
        ),
        currentState: const FusionSessionState(),
      );
      final second = useCase.execute(
        chunk: ImuChunkEntity(
          sessionId: 4,
          capturedAtUtc: DateTime.utc(2026, 4, 29, 16, 0, 1),
          chunkStartMonotonicNs: 0,
          sampleCount: biasedStaticEvents.length,
          samplingHz: 50,
          payload: _encodeSensorEvents(biasedStaticEvents),
          payloadFormat: 'imu-sensor-event-le-v1',
        ),
        currentState: first.nextState,
      );

      expect(_metricValue(first.metrics, 'quality_calibration_missing'), 0);
      expect(
        _metricValue(second.metrics, 'turn_rate_deg_s').abs(),
        lessThan(2.0),
      );
    });

    test('flags magnetic instability when magnetometer norm is noisy', () {
      const useCase = ProcessImuChunkUseCase();
      final noisyEvents = <_EncodedEvent>[
        _EncodedEvent(1, 4_000_000_000, 0, 0, 9.80665, 3),
        _EncodedEvent(2, 4_000_000_001, 10, 0, 0, 3),
        _EncodedEvent(4, 4_000_000_002, 0, 0, 0, 3),
        _EncodedEvent(1, 4_020_000_000, 0, 0, 9.80665, 3),
        _EncodedEvent(2, 4_020_000_001, 80, 0, 0, 3),
        _EncodedEvent(4, 4_020_000_002, 0, 0, 0, 3),
        _EncodedEvent(1, 4_040_000_000, 0, 0, 9.80665, 3),
        _EncodedEvent(2, 4_040_000_001, 12, 0, 0, 3),
        _EncodedEvent(4, 4_040_000_002, 0, 0, 0, 3),
        _EncodedEvent(1, 4_060_000_000, 0, 0, 9.80665, 3),
        _EncodedEvent(2, 4_060_000_001, 90, 0, 0, 3),
        _EncodedEvent(4, 4_060_000_002, 0, 0, 0, 3),
      ];

      final result = useCase.execute(
        chunk: ImuChunkEntity(
          sessionId: 5,
          capturedAtUtc: DateTime.utc(2026, 4, 29, 16, 10),
          chunkStartMonotonicNs: 0,
          sampleCount: noisyEvents.length,
          samplingHz: 50,
          payload: _encodeSensorEvents(noisyEvents),
          payloadFormat: 'imu-sensor-event-le-v1',
        ),
        currentState: const FusionSessionState(hasCalibration: true),
      );

      expect(_metricValue(result.metrics, 'quality_magnetic_instability'), 1);
    });

    test('flags stale data when GPS context is missing', () {
      const useCase = ProcessImuChunkUseCase();
      final result = useCase.execute(
        chunk: ImuChunkEntity(
          sessionId: 6,
          capturedAtUtc: DateTime.utc(2026, 4, 29, 16, 20),
          chunkStartMonotonicNs: 0,
          sampleCount: 18,
          samplingHz: 50,
          payload: _encodeSensorEvents(<_EncodedEvent>[
            ..._stationaryEvents(baseTimestampNs: 5_000_000_000),
            ..._stationaryEvents(baseTimestampNs: 5_200_000_000),
          ]),
          payloadFormat: 'imu-sensor-event-le-v1',
        ),
        currentState: const FusionSessionState(hasCalibration: true),
      );

      expect(_metricValue(result.metrics, 'quality_stale_data'), 1);
    });

    test('does not validate heading by GPS when boat speed is too low', () {
      const useCase = ProcessImuChunkUseCase();
      final result = useCase.execute(
        chunk: ImuChunkEntity(
          sessionId: 7,
          capturedAtUtc: DateTime.utc(2026, 4, 29, 16, 30),
          chunkStartMonotonicNs: 0,
          sampleCount: 18,
          samplingHz: 50,
          payload: _encodeSensorEvents(<_EncodedEvent>[
            ..._stationaryEvents(baseTimestampNs: 6_000_000_000),
            ..._stationaryEvents(baseTimestampNs: 6_200_000_000),
          ]),
          payloadFormat: 'imu-sensor-event-le-v1',
        ),
        currentState: const FusionSessionState(hasCalibration: true),
        recentGpsPoints: <TrackingPointEntity>[
          TrackingPointEntity(
            timestampUtc: DateTime.utc(2026, 4, 29, 16, 30),
            longitude: 30.001,
            latitude: 60.001,
            speedMetersPerSecond: 0.5,
          ),
          TrackingPointEntity(
            timestampUtc: DateTime.utc(2026, 4, 29, 16, 29, 59),
            longitude: 30.0,
            latitude: 60.0,
            speedMetersPerSecond: 0.5,
          ),
        ],
      );

      expect(
        _metricValue(result.metrics, 'quality_heading_validated_by_gps'),
        0,
      );
    });

    test('rejects incomplete IMU payload records', () {
      const useCase = ProcessImuChunkUseCase();

      expect(
        () => useCase.execute(
          chunk: ImuChunkEntity(
            sessionId: 8,
            capturedAtUtc: DateTime.utc(2026, 4, 29, 16, 40),
            chunkStartMonotonicNs: 0,
            sampleCount: 1,
            samplingHz: 50,
            payload: Uint8List.fromList(const <int>[1, 2, 3]),
            payloadFormat: 'imu-sensor-event-le-v1',
          ),
          currentState: const FusionSessionState(),
        ),
        throwsArgumentError,
      );
    });
  });

  test(
    'TrackingSampleIngestionService stores gps, imu chunks and derived metrics',
    () async {
      final tempDir = await Directory.systemTemp.createTemp('fusion-ingest');
      final chunkFile = File('${tempDir.path}${Platform.pathSeparator}imu.bin');
      await chunkFile.writeAsBytes(
        _encodeSensorEvents(<_EncodedEvent>[
          ..._stationaryEvents(baseTimestampNs: 3_000_000_000),
          ..._turnEvents(baseTimestampNs: 3_200_000_000, gyroZ: 0.4),
        ]),
      );

      final sensorBridge = _FakeSensorBridgeRepository();
      final trackingSessionRepository = _FakeTrackingSessionRepository();
      final trackingRepository = _FakeTrackingRepository();
      final ingestionService = TrackingSampleIngestionService(
        sensorBridgeRepository: sensorBridge,
        trackingSessionRepository: trackingSessionRepository,
        trackingRepository: trackingRepository,
      );
      final session = TrackingSessionEntity(
        id: 12,
        raceId: 901,
        role: 'participant',
        state: TrackingSessionState.tracking,
        intervalSeconds: 1,
        startedAtUtc: DateTime.utc(2026, 4, 29, 17, 0, 0),
      );

      trackingRepository.recentGpsPoints = <TrackingPointEntity>[
        TrackingPointEntity(
          sessionId: 12,
          timestampUtc: DateTime.utc(2026, 4, 29, 17, 0, 0),
          longitude: 30.0,
          latitude: 60.0,
          speedMetersPerSecond: 3.5,
        ),
        TrackingPointEntity(
          sessionId: 12,
          timestampUtc: DateTime.utc(2026, 4, 29, 16, 59, 55),
          longitude: 29.9995,
          latitude: 59.9995,
          speedMetersPerSecond: 3.5,
        ),
      ];

      await ingestionService.bind(session);
      sensorBridge.emit(
        SampleBatch(
          sessionId: '12',
          recordedAt: DateTime.utc(2026, 4, 29, 17, 0, 1),
          gpsPoints: <GpsSample>[
            GpsSample(
              timestamp: DateTime.utc(2026, 4, 29, 17, 0, 1),
              longitude: 30.0004,
              latitude: 60.0004,
              speedMetersPerSecond: 3.8,
            ),
          ],
          imuChunkRefs: <ImuChunkRef>[
            ImuChunkRef(
              chunkId: 'imu_1',
              startedAt: DateTime.utc(2026, 4, 29, 17, 0, 1),
              sampleCount: 18,
              storagePath: chunkFile.path,
            ),
          ],
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 250));
      await ingestionService.dispose();

      expect(trackingSessionRepository.savedGpsPoints, hasLength(1));
      expect(trackingRepository.savedChunks, hasLength(1));
      expect(trackingRepository.savedDerivedMetrics, isNotEmpty);
      expect(
        trackingRepository.savedDerivedMetrics.any(
          (metric) => metric.metricType == 'heading_deg',
        ),
        isTrue,
      );

      await tempDir.delete(recursive: true);
    },
  );
}

class _FakeSensorBridgeRepository implements SensorBridgeRepository {
  final StreamController<SampleBatch> _samples =
      StreamController<SampleBatch>.broadcast();

  void emit(SampleBatch batch) {
    _samples.add(batch);
  }

  @override
  Future<TrackingHealth> requestRequiredPermissions() async =>
      TrackingHealth.unknown;

  @override
  Future<SessionStatus?> getSessionStatus({required String sessionId}) async =>
      null;

  @override
  Future<SessionStatus> pauseTrackingSession({required String sessionId}) {
    throw UnimplementedError();
  }

  @override
  Future<TrackingHealth> readTrackingHealth({String? sessionId}) async =>
      TrackingHealth.unknown;

  @override
  Future<SessionStatus> resumeTrackingSession({required String sessionId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setTrackingProfile({
    required String sessionId,
    required TrackingProfile profile,
  }) async {}

  @override
  Future<SessionStatus> startTrackingSession({required SessionConfig config}) {
    throw UnimplementedError();
  }

  @override
  Future<SessionStatus> stopTrackingSession({required String sessionId}) {
    throw UnimplementedError();
  }

  @override
  Stream<HealthEvent> streamHealth({String? sessionId}) =>
      const Stream<HealthEvent>.empty();

  @override
  Stream<SampleBatch> streamSamples({String? sessionId}) => _samples.stream;

  @override
  Stream<TrackingHealth> watchTrackingHealth({String? sessionId}) =>
      const Stream<TrackingHealth>.empty();
}

class _FakeTrackingSessionRepository implements TrackingSessionRepository {
  final List<TrackingPointEntity> savedGpsPoints = <TrackingPointEntity>[];

  @override
  Future<TrackingSessionEntity> createSession({
    required int raceId,
    required String role,
    required int intervalSeconds,
    required TrackingSessionState state,
    String? sensorHealthSnapshot,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<int> getPendingSyncCount({int? sessionId}) async => 0;

  @override
  Future<TrackingPointEntity?> loadLatestGpsPoint(int sessionId) async => null;

  @override
  Future<List<SyncJobEntity>> loadPendingSyncJobs() async =>
      const <SyncJobEntity>[];

  @override
  Future<TrackingSessionEntity?> restoreSession() async => null;

  @override
  Future<void> saveGpsPoint(TrackingPointEntity point) async {
    savedGpsPoints.add(point);
  }

  @override
  Future<void> queueGpsPointForSync(TrackingPointEntity point) async {}

  @override
  Future<TrackingSessionEntity> transitionSessionState({
    required int sessionId,
    required TrackingSessionState state,
    DateTime? endedAtUtc,
    String? failureReason,
    DateTime? lastSyncAtUtc,
    String? sensorHealthSnapshot,
  }) {
    throw UnimplementedError();
  }
}

class _FakeTrackingRepository implements TrackingRepository {
  final List<ImuChunkEntity> savedChunks = <ImuChunkEntity>[];
  final List<DerivedMetricEntity> savedDerivedMetrics = <DerivedMetricEntity>[];
  List<TrackingPointEntity> recentGpsPoints = <TrackingPointEntity>[];

  @override
  Future<TrackingSessionEntity> createSession({
    required int raceId,
    required String role,
    required int intervalSeconds,
    String? sensorHealthSnapshot,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasImuChunk({
    required int sessionId,
    required DateTime capturedAtUtc,
  }) async {
    return savedChunks.any((chunk) {
      return chunk.sessionId == sessionId &&
          chunk.capturedAtUtc == capturedAtUtc;
    });
  }

  @override
  Future<List<DerivedMetricEntity>> loadDerivedMetricsForSession(
    int sessionId, {
    int? limit,
  }) async {
    return savedDerivedMetrics
        .where((metric) => metric.sessionId == sessionId)
        .take(limit ?? savedDerivedMetrics.length)
        .toList(growable: false);
  }

  @override
  Future<List<TrackingPointEntity>> loadGpsPointsForSession(
    int sessionId,
  ) async => recentGpsPoints;

  @override
  Future<TrackingPointEntity?> loadLatestGpsPointForSession(
    int sessionId,
  ) async => recentGpsPoints.isEmpty ? null : recentGpsPoints.first;

  @override
  Future<TrackingSessionEntity?> loadLatestUnfinishedSession() async => null;

  @override
  Future<List<TrackingPointEntity>> loadRecentGpsPointsForSession(
    int sessionId, {
    int limit = 2,
  }) async {
    return recentGpsPoints.take(limit).toList(growable: false);
  }

  @override
  Future<TrackingSessionEntity?> loadSessionById(int sessionId) async => null;

  @override
  Future<void> saveDerivedMetrics(List<DerivedMetricEntity> metrics) async {
    savedDerivedMetrics.addAll(metrics);
  }

  @override
  Future<void> saveGpsPoint({required TrackingPointEntity point}) async {
    recentGpsPoints = <TrackingPointEntity>[point, ...recentGpsPoints];
  }

  @override
  Future<void> saveImuChunk({required ImuChunkEntity chunk}) async {
    savedChunks.add(chunk);
  }

  @override
  Future<void> transitionSessionState({
    required int sessionId,
    required TrackingSessionState state,
    DateTime? endedAtUtc,
    String? failureReason,
    DateTime? lastSyncAtUtc,
    String? sensorHealthSnapshot,
  }) {
    throw UnimplementedError();
  }
}

double _metricValue(List<DerivedMetricEntity> metrics, String type) {
  return metrics.firstWhere((metric) => metric.metricType == type).metricValue;
}

List<_EncodedEvent> _stationaryEvents({
  required int baseTimestampNs,
  double gyroZ = 0.0,
}) {
  return <_EncodedEvent>[
    _EncodedEvent(1, baseTimestampNs, 0, 0, 9.80665, 3),
    _EncodedEvent(2, baseTimestampNs + 1, 25, 0, 0, 3),
    _EncodedEvent(4, baseTimestampNs + 2, 0, 0, gyroZ, 3),
    _EncodedEvent(1, baseTimestampNs + 20_000_000, 0, 0, 9.80665, 3),
    _EncodedEvent(2, baseTimestampNs + 20_000_001, 25, 0, 0, 3),
    _EncodedEvent(4, baseTimestampNs + 20_000_002, 0, 0, gyroZ, 3),
    _EncodedEvent(1, baseTimestampNs + 40_000_000, 0, 0, 9.80665, 3),
    _EncodedEvent(2, baseTimestampNs + 40_000_001, 25, 0, 0, 3),
    _EncodedEvent(4, baseTimestampNs + 40_000_002, 0, 0, gyroZ, 3),
  ];
}

List<_EncodedEvent> _turnEvents({
  required int baseTimestampNs,
  required double gyroZ,
}) {
  return <_EncodedEvent>[
    _EncodedEvent(1, baseTimestampNs, 0, 0, 9.80665, 3),
    _EncodedEvent(2, baseTimestampNs + 1, 25, 0, 0, 3),
    _EncodedEvent(4, baseTimestampNs + 2, 0, 0, gyroZ, 3),
    _EncodedEvent(1, baseTimestampNs + 20_000_000, 0.1, 0, 9.70, 3),
    _EncodedEvent(2, baseTimestampNs + 20_000_001, 24.8, 1.2, 0.1, 3),
    _EncodedEvent(4, baseTimestampNs + 20_000_002, 0, 0, gyroZ, 3),
    _EncodedEvent(1, baseTimestampNs + 40_000_000, 0.2, 0, 9.65, 3),
    _EncodedEvent(2, baseTimestampNs + 40_000_001, 24.5, 2.0, 0.2, 3),
    _EncodedEvent(4, baseTimestampNs + 40_000_002, 0, 0, gyroZ, 3),
  ];
}

Uint8List _encodeSensorEvents(List<_EncodedEvent> events) {
  final data = ByteData(events.length * 28);
  for (int index = 0; index < events.length; index += 1) {
    final offset = index * 28;
    final event = events[index];
    data.setInt32(offset, event.sensorType, Endian.little);
    data.setInt64(offset + 4, event.timestampNs, Endian.little);
    data.setFloat32(offset + 12, event.x, Endian.little);
    data.setFloat32(offset + 16, event.y, Endian.little);
    data.setFloat32(offset + 20, event.z, Endian.little);
    data.setInt32(offset + 24, event.accuracy, Endian.little);
  }
  return data.buffer.asUint8List();
}

class _EncodedEvent {
  const _EncodedEvent(
    this.sensorType,
    this.timestampNs,
    this.x,
    this.y,
    this.z,
    this.accuracy,
  );

  final int sensorType;
  final int timestampNs;
  final double x;
  final double y;
  final double z;
  final int accuracy;
}
