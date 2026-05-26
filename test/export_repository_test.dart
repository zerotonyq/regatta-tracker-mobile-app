import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';
import 'package:vkr_regatta/src/core/config/app_config.dart';
import 'package:vkr_regatta/src/features/export/data/export_repository_impl.dart';
import 'package:vkr_regatta/src/features/export/domain/export_format.dart';
import 'package:vkr_regatta/src/features/local_storage/database/app_database.dart';
import 'package:vkr_regatta/src/features/sensor_bridge/domain/sensor_bridge_repository.dart';
import 'package:vkr_regatta/src/features/tracking/data/tracking_repository_impl.dart';
import 'package:vkr_regatta/src/features/tracking/domain/derived_metric_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/imu_chunk_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_health.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_point_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_session_entity.dart';

void main() {
  test('builds session summaries and all export formats from local db', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    final trackingRepository = TrackingRepositoryImpl(database);
    final tempDir = await Directory.systemTemp.createTemp('regatta-export');
    final session = await trackingRepository.createSession(
      raceId: 9001,
      role: 'participant',
      intervalSeconds: 2,
      sensorHealthSnapshot:
          'gpsEnabled=true;imuEnabled=true;pendingSync=0;dropped=2;gpsAccuracy=3.10',
    );

    await trackingRepository.saveGpsPoint(
      point: TrackingPointEntity(
        sessionId: session.id,
        timestampUtc: DateTime.utc(2026, 4, 29, 18, 0, 0),
        latitude: 60.0,
        longitude: 30.0,
        speedMetersPerSecond: 4.0,
      ),
    );
    await trackingRepository.saveGpsPoint(
      point: TrackingPointEntity(
        sessionId: session.id,
        timestampUtc: DateTime.utc(2026, 4, 29, 18, 0, 2),
        latitude: 60.0003,
        longitude: 30.0004,
        speedMetersPerSecond: 4.4,
      ),
    );
    await trackingRepository.saveDerivedMetrics(<DerivedMetricEntity>[
      DerivedMetricEntity(
        sessionId: session.id,
        timestampUtc: DateTime.utc(2026, 4, 29, 18, 0, 2),
        metricType: 'heading_deg',
        metricValue: 18.5,
        unit: 'deg',
      ),
      DerivedMetricEntity(
        sessionId: session.id,
        timestampUtc: DateTime.utc(2026, 4, 29, 18, 0, 2),
        metricType: 'heel_deg',
        metricValue: 7.2,
        unit: 'deg',
      ),
    ]);
    await trackingRepository.saveImuChunk(
      chunk: ImuChunkEntity(
        sessionId: session.id,
        capturedAtUtc: DateTime.utc(2026, 4, 29, 18, 0, 1),
        chunkStartMonotonicNs: 100,
        sampleCount: 64,
        samplingHz: 50,
        payload: Uint8List.fromList(const <int>[1, 2, 3]),
      ),
    );
    await trackingRepository.transitionSessionState(
      sessionId: session.id,
      state: TrackingSessionState.completed,
      endedAtUtc: DateTime.utc(2026, 4, 29, 18, 5, 0),
      lastSyncAtUtc: DateTime.utc(2026, 4, 29, 18, 5, 5),
      sensorHealthSnapshot:
          'gpsEnabled=true;imuEnabled=true;pendingSync=0;dropped=2;gpsAccuracy=3.10',
    );

    final repository = ExportRepositoryImpl(
      appDatabase: database,
      sensorBridgeRepository: _FakeSensorBridgeRepository(),
      config: AppConfig(
        baseUrl: 'http://localhost',
        userAgent: 'vkr-regatta-mobile/1.0.0',
        connectTimeoutMs: 1000,
        receiveTimeoutMs: 1000,
        useMockApi: true,
      ),
      exportRootDirectory: tempDir,
    );

    final sessions = await repository.loadCompletedSessions();
    expect(sessions, hasLength(1));
    expect(sessions.single.gpsPointCount, 2);
    expect(sessions.single.imuChunkCount, 1);
    expect(sessions.single.derivedMetricSummary['heading_deg'], 18.5);

    final csv = await repository.buildExport(
      sessionId: session.id,
      format: ExportFormat.csv,
    );
    final zip = await repository.buildExport(
      sessionId: session.id,
      format: ExportFormat.zipBundle,
    );
    final diagnostics = await repository.buildExport(
      sessionId: session.id,
      format: ExportFormat.diagnosticsJson,
    );

    expect(csv.fileName, endsWith('.csv'));
    expect(await File(csv.filePath).exists(), isTrue);
    expect(zip.fileName, endsWith('.zip'));
    expect(await File(zip.filePath).exists(), isTrue);
    final archive = ZipDecoder().decodeBytes(zip.bytes);
    final archiveNames = archive.files.map((file) => file.name).toSet();
    expect(archiveNames, contains('manifest.json'));
    expect(archiveNames, contains('derived_metrics.csv'));
    expect(archiveNames, contains('derived_metrics.json'));
    expect(archiveNames.any((name) => name.startsWith('imu_chunks/')), isTrue);
    expect(diagnostics.fileName, contains('diagnostics'));
    expect(await File(diagnostics.filePath).exists(), isTrue);

    await database.close();
    await tempDir.delete(recursive: true);
  });
}

class _FakeSensorBridgeRepository implements SensorBridgeRepository {
  @override
  Future<TrackingHealth> requestRequiredPermissions() {
    return readTrackingHealth();
  }

  @override
  Future<SessionStatus?> getSessionStatus({required String sessionId}) async =>
      null;

  @override
  Future<SessionStatus> pauseTrackingSession({required String sessionId}) {
    throw UnimplementedError();
  }

  @override
  Future<TrackingHealth> readTrackingHealth({String? sessionId}) async {
    return const TrackingHealth(
      locationPermission: TrackingPermissionState.granted,
      motionPermission: TrackingPermissionState.granted,
      gpsEnabled: true,
      imuEnabled: true,
      backgroundServiceRunning: true,
      pendingSyncCount: 0,
      droppedSampleCount: 2,
      activeTrackingProfile: TrackingProfile.raceCruise,
    );
  }

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
  Stream<SampleBatch> streamSamples({String? sessionId}) =>
      const Stream<SampleBatch>.empty();

  @override
  Stream<TrackingHealth> watchTrackingHealth({String? sessionId}) =>
      const Stream<TrackingHealth>.empty();
}
