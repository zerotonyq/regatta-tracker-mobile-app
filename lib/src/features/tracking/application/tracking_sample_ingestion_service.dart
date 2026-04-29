import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

import '../../sensor_bridge/domain/sensor_bridge_repository.dart';
import '../../sensor_fusion/application/process_imu_chunk_use_case.dart';
import '../../sensor_fusion/domain/fusion_session_state.dart';
import 'live_tracking_delivery_service.dart';
import '../domain/derived_metric_entity.dart';
import '../domain/imu_chunk_entity.dart';
import '../domain/tracking_point_entity.dart';
import '../domain/tracking_repository.dart';
import '../domain/tracking_session_entity.dart';
import '../domain/tracking_session_repository.dart';

class TrackingSampleIngestionService {
  TrackingSampleIngestionService({
    required SensorBridgeRepository sensorBridgeRepository,
    required TrackingSessionRepository trackingSessionRepository,
    required TrackingRepository trackingRepository,
    LiveTrackingDeliveryService? liveTrackingDeliveryService,
  }) : _sensorBridgeRepository = sensorBridgeRepository,
       _trackingSessionRepository = trackingSessionRepository,
       _trackingRepository = trackingRepository,
       _liveTrackingDeliveryService = liveTrackingDeliveryService;

  final SensorBridgeRepository _sensorBridgeRepository;
  final TrackingSessionRepository _trackingSessionRepository;
  final TrackingRepository _trackingRepository;
  final LiveTrackingDeliveryService? _liveTrackingDeliveryService;

  StreamSubscription<SampleBatch>? _sampleSubscription;
  Future<void> _pipeline = Future<void>.value();
  final Map<int, FusionSessionState> _sessionStates =
      <int, FusionSessionState>{};

  Future<void> bind(TrackingSessionEntity session) async {
    await _sampleSubscription?.cancel();
    _sampleSubscription = _sensorBridgeRepository
        .streamSamples(sessionId: session.id.toString())
        .listen((SampleBatch batch) {
          _pipeline = _pipeline.then((_) => _ingestBatch(session.id, batch));
        });
  }

  Future<void> unbind() async {
    await _sampleSubscription?.cancel();
    _sampleSubscription = null;
  }

  Future<void> dispose() async {
    await unbind();
    await _pipeline;
  }

  Future<void> _ingestBatch(int sessionId, SampleBatch batch) async {
    for (final GpsSample point in batch.gpsPoints) {
      final trackingPoint = TrackingPointEntity(
        sessionId: sessionId,
        timestampUtc: point.timestamp,
        longitude: point.longitude,
        latitude: point.latitude,
        accuracyMeters: point.accuracyMeters,
        speedMetersPerSecond: point.speedMetersPerSecond,
      );
      final deliveryService = _liveTrackingDeliveryService;
      if (deliveryService == null) {
        await _trackingSessionRepository.saveGpsPoint(trackingPoint);
      } else {
        await deliveryService.deliverPoint(
          sessionId: sessionId,
          point: trackingPoint,
        );
      }
    }

    for (final ImuChunkRef chunkRef in batch.imuChunkRefs) {
      await _importAndProcessImuChunk(sessionId: sessionId, chunkRef: chunkRef);
    }
  }

  Future<void> _importAndProcessImuChunk({
    required int sessionId,
    required ImuChunkRef chunkRef,
  }) async {
    final storagePath = chunkRef.storagePath;
    if (storagePath == null || storagePath.isEmpty) {
      return;
    }
    final capturedAtUtc = chunkRef.startedAt.toUtc();
    final alreadyImported = await _trackingRepository.hasImuChunk(
      sessionId: sessionId,
      capturedAtUtc: capturedAtUtc,
    );
    if (alreadyImported) {
      return;
    }

    final payload = await File(storagePath).readAsBytes();
    final chunk = ImuChunkEntity(
      sessionId: sessionId,
      capturedAtUtc: capturedAtUtc,
      chunkStartMonotonicNs: 0,
      sampleCount: chunkRef.sampleCount,
      samplingHz: 50,
      payload: Uint8List.fromList(payload),
      payloadFormat: 'imu-sensor-event-le-v1',
    );
    await _trackingRepository.saveImuChunk(chunk: chunk);

    final recentGpsPoints = await _trackingRepository
        .loadRecentGpsPointsForSession(sessionId, limit: 2);
    final currentState =
        _sessionStates[sessionId] ?? const FusionSessionState();
    final request = <String, Object?>{
      'sessionId': chunk.sessionId,
      'capturedAtUtc': chunk.capturedAtUtc.toIso8601String(),
      'chunkStartMonotonicNs': chunk.chunkStartMonotonicNs,
      'sampleCount': chunk.sampleCount,
      'samplingHz': chunk.samplingHz,
      'payload': chunk.payload,
      'payloadFormat': chunk.payloadFormat,
      'recentGpsPoints': recentGpsPoints
          .map<Map<String, Object?>>((TrackingPointEntity point) {
            return <String, Object?>{
              'timestampUtc': point.timestampUtc.toIso8601String(),
              'longitude': point.longitude,
              'latitude': point.latitude,
              'accuracyMeters': point.accuracyMeters,
              'speedMetersPerSecond': point.speedMetersPerSecond,
            };
          })
          .toList(growable: false),
      'state': <String, Object?>{
        'accelerometerBias': currentState.accelerometerBias,
        'gyroscopeBias': currentState.gyroscopeBias,
        'magnetometerBias': currentState.magnetometerBias,
        'rollRad': currentState.rollRad,
        'pitchRad': currentState.pitchRad,
        'yawRad': currentState.yawRad,
        'smoothedAccelerationMetersPerSecond2':
            currentState.smoothedAccelerationMetersPerSecond2,
        'lastGyroTimestampNs': currentState.lastGyroTimestampNs,
        'calibrationSampleCount': currentState.calibrationSampleCount,
        'hasCalibration': currentState.hasCalibration,
      },
    };
    final response = await _runChunkInIsolate(request);

    _sessionStates[sessionId] = _stateFromMap(
      response['nextState']! as Map<Object?, Object?>,
    );
    await _trackingRepository.saveDerivedMetrics(
      (response['metrics']! as List<Object?>)
          .map((Object? item) {
            final map = item! as Map<Object?, Object?>;
            return _metricFromMap(map);
          })
          .toList(growable: false),
    );
  }

  FusionSessionState _stateFromMap(Map<Object?, Object?> map) {
    return FusionSessionState(
      accelerometerBias: _doubleList(map['accelerometerBias']),
      gyroscopeBias: _doubleList(map['gyroscopeBias']),
      magnetometerBias: _doubleList(map['magnetometerBias']),
      rollRad: (map['rollRad'] as num).toDouble(),
      pitchRad: (map['pitchRad'] as num).toDouble(),
      yawRad: (map['yawRad'] as num).toDouble(),
      smoothedAccelerationMetersPerSecond2:
          (map['smoothedAccelerationMetersPerSecond2'] as num).toDouble(),
      lastGyroTimestampNs: (map['lastGyroTimestampNs'] as num?)?.toInt(),
      calibrationSampleCount: (map['calibrationSampleCount'] as num).toInt(),
      hasCalibration: map['hasCalibration'] as bool,
    );
  }

  List<double> _doubleList(Object? raw) {
    return (raw as List<Object?>)
        .map((Object? value) {
          return (value as num).toDouble();
        })
        .toList(growable: false);
  }

  DerivedMetricEntity _metricFromMap(Map<Object?, Object?> map) {
    return DerivedMetricEntity(
      sessionId: (map['sessionId'] as num).toInt(),
      timestampUtc: DateTime.parse(map['timestampUtc'] as String).toUtc(),
      metricType: map['metricType'] as String,
      metricValue: (map['metricValue'] as num).toDouble(),
      unit: map['unit'] as String?,
    );
  }
}

Map<String, Object?> _processChunkInBackground(Map<String, Object?> request) {
  final service = const ProcessImuChunkUseCase();
  final stateMap = request['state']! as Map<Object?, Object?>;
  final state = FusionSessionState(
    accelerometerBias: (stateMap['accelerometerBias']! as List<Object?>)
        .map((Object? value) => (value as num).toDouble())
        .toList(growable: false),
    gyroscopeBias: (stateMap['gyroscopeBias']! as List<Object?>)
        .map((Object? value) => (value as num).toDouble())
        .toList(growable: false),
    magnetometerBias: (stateMap['magnetometerBias']! as List<Object?>)
        .map((Object? value) => (value as num).toDouble())
        .toList(growable: false),
    rollRad: (stateMap['rollRad'] as num).toDouble(),
    pitchRad: (stateMap['pitchRad'] as num).toDouble(),
    yawRad: (stateMap['yawRad'] as num).toDouble(),
    smoothedAccelerationMetersPerSecond2:
        (stateMap['smoothedAccelerationMetersPerSecond2'] as num).toDouble(),
    lastGyroTimestampNs: (stateMap['lastGyroTimestampNs'] as num?)?.toInt(),
    calibrationSampleCount: (stateMap['calibrationSampleCount'] as num).toInt(),
    hasCalibration: stateMap['hasCalibration'] as bool,
  );
  final chunk = ImuChunkEntity(
    sessionId: (request['sessionId'] as num).toInt(),
    capturedAtUtc: DateTime.parse(request['capturedAtUtc'] as String).toUtc(),
    chunkStartMonotonicNs: (request['chunkStartMonotonicNs'] as num).toInt(),
    sampleCount: (request['sampleCount'] as num).toInt(),
    samplingHz: (request['samplingHz'] as num).toInt(),
    payload: request['payload'] as Uint8List,
    payloadFormat: request['payloadFormat'] as String,
  );
  final recentGpsPoints = (request['recentGpsPoints'] as List<Object?>)
      .map((Object? item) {
        final map = item! as Map<Object?, Object?>;
        return TrackingPointEntity(
          timestampUtc: DateTime.parse(map['timestampUtc'] as String).toUtc(),
          longitude: (map['longitude'] as num).toDouble(),
          latitude: (map['latitude'] as num).toDouble(),
          accuracyMeters: (map['accuracyMeters'] as num?)?.toDouble(),
          speedMetersPerSecond: (map['speedMetersPerSecond'] as num?)
              ?.toDouble(),
        );
      })
      .toList(growable: false);

  final processed = service.execute(
    chunk: chunk,
    currentState: state,
    recentGpsPoints: recentGpsPoints,
  );
  return <String, Object?>{
    'nextState': <String, Object?>{
      'accelerometerBias': processed.nextState.accelerometerBias,
      'gyroscopeBias': processed.nextState.gyroscopeBias,
      'magnetometerBias': processed.nextState.magnetometerBias,
      'rollRad': processed.nextState.rollRad,
      'pitchRad': processed.nextState.pitchRad,
      'yawRad': processed.nextState.yawRad,
      'smoothedAccelerationMetersPerSecond2':
          processed.nextState.smoothedAccelerationMetersPerSecond2,
      'lastGyroTimestampNs': processed.nextState.lastGyroTimestampNs,
      'calibrationSampleCount': processed.nextState.calibrationSampleCount,
      'hasCalibration': processed.nextState.hasCalibration,
    },
    'metrics': processed.metrics
        .map((metric) {
          return <String, Object?>{
            'sessionId': metric.sessionId,
            'timestampUtc': metric.timestampUtc.toIso8601String(),
            'metricType': metric.metricType,
            'metricValue': metric.metricValue,
            'unit': metric.unit,
          };
        })
        .toList(growable: false),
  };
}

Future<Map<String, Object?>> _runChunkInIsolate(Map<String, Object?> request) {
  return Isolate.run<Map<String, Object?>>(
    () => _processChunkInBackground(request),
  );
}
