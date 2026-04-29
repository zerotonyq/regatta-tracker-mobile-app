import 'dart:math' as math;

import '../../tracking/domain/derived_metric_entity.dart';
import '../../tracking/domain/imu_chunk_entity.dart';
import '../../tracking/domain/tracking_point_entity.dart';
import '../algorithms/complementary_filter.dart';
import '../domain/fusion_session_state.dart';
import '../domain/fusion_quality_flag.dart';
import '../domain/imu_sensor_event_entity.dart';
import 'compute_orientation_use_case.dart';
import 'heading_normalizer.dart';
import 'imu_calibration_service.dart';
import 'imu_payload_codec.dart';

class ProcessImuChunkUseCase {
  const ProcessImuChunkUseCase({
    ImuPayloadCodec imuPayloadCodec = const ImuPayloadCodec(),
    ImuCalibrationService imuCalibrationService = const ImuCalibrationService(),
    ComputeOrientationUseCase? computeOrientationUseCase,
    HeadingNormalizer headingNormalizer = const HeadingNormalizer(),
  }) : _imuPayloadCodec = imuPayloadCodec,
       _imuCalibrationService = imuCalibrationService,
       _computeOrientationUseCase =
           computeOrientationUseCase ??
           const ComputeOrientationUseCase(ComplementaryFilter()),
       _headingNormalizer = headingNormalizer;

  final ImuPayloadCodec _imuPayloadCodec;
  final ImuCalibrationService _imuCalibrationService;
  final ComputeOrientationUseCase _computeOrientationUseCase;
  final HeadingNormalizer _headingNormalizer;

  ProcessedImuChunk execute({
    required ImuChunkEntity chunk,
    required FusionSessionState currentState,
    List<TrackingPointEntity> recentGpsPoints = const <TrackingPointEntity>[],
  }) {
    final events = _imuPayloadCodec.decode(
      payload: chunk.payload,
      payloadFormat: chunk.payloadFormat,
    );
    final calibratedState = currentState.hasCalibration
        ? currentState
        : _imuCalibrationService.updateCalibration(
            currentState: currentState,
            events: events,
          );
    final gpsCourseOverGroundDegrees = _resolveGpsCourseOverGroundDegrees(
      recentGpsPoints,
    );
    final magneticInstability = _hasMagneticInstability(events);
    final staleData = _hasStaleData(
      chunk: chunk,
      recentGpsPoints: recentGpsPoints,
    );
    final filterResult = _computeOrientationUseCase.execute(
      initialState: calibratedState,
      events: events,
      timestampUtc: chunk.capturedAtUtc,
      gpsCourseOverGroundDegrees: gpsCourseOverGroundDegrees,
      calibrationMissing: !calibratedState.hasCalibration,
      magneticInstability: magneticInstability,
      staleData: staleData,
    );

    final metrics = <DerivedMetricEntity>[
      _metric(chunk, 'roll_deg', filterResult.frame.rollDegrees, 'deg'),
      _metric(chunk, 'pitch_deg', filterResult.frame.pitchDegrees, 'deg'),
      _metric(chunk, 'yaw_deg', filterResult.frame.yawDegrees, 'deg'),
      _metric(chunk, 'heading_deg', filterResult.frame.headingDegrees, 'deg'),
      _metric(chunk, 'heel_deg', filterResult.frame.heelDegrees, 'deg'),
      _metric(
        chunk,
        'turn_rate_deg_s',
        filterResult.frame.turnRateDegreesPerSecond,
        'deg/s',
      ),
      _metric(
        chunk,
        'smoothed_accel_mps2',
        filterResult.frame.smoothedAccelerationMetersPerSecond2,
        'm/s2',
      ),
      ...FusionQualityFlag.values.map((FusionQualityFlag flag) {
        return _metric(
          chunk,
          flag.metricType,
          filterResult.frame.qualityFlags.contains(flag) ? 1 : 0,
          'bool',
        );
      }),
    ];

    return ProcessedImuChunk(
      nextState: filterResult.nextState.copyWith(
        hasCalibration: calibratedState.hasCalibration,
        accelerometerBias: calibratedState.accelerometerBias,
        gyroscopeBias: calibratedState.gyroscopeBias,
        magnetometerBias: calibratedState.magnetometerBias,
        calibrationSampleCount: calibratedState.calibrationSampleCount,
      ),
      decodedEvents: events,
      metrics: metrics,
    );
  }

  DerivedMetricEntity _metric(
    ImuChunkEntity chunk,
    String type,
    double value,
    String unit,
  ) {
    return DerivedMetricEntity(
      sessionId: chunk.sessionId,
      timestampUtc: chunk.capturedAtUtc,
      metricType: type,
      metricValue: value,
      unit: unit,
    );
  }

  bool _hasMagneticInstability(List<ImuSensorEventEntity> events) {
    final magnetometerEvents = events
        .where((ImuSensorEventEntity event) {
          return event.sensorType == ImuSensorType.magnetometer;
        })
        .toList(growable: false);
    if (magnetometerEvents.length < 4) {
      return true;
    }

    final norms = magnetometerEvents
        .map((ImuSensorEventEntity event) {
          return _vectorNorm(event.vector);
        })
        .toList(growable: false);
    final mean = norms.reduce((double a, double b) => a + b) / norms.length;
    if (mean <= 0) {
      return true;
    }
    double variance = 0;
    for (final double norm in norms) {
      final delta = norm - mean;
      variance += delta * delta;
    }
    variance /= norms.length;
    final normalizedStdDev = math.sqrt(variance) / mean;
    return normalizedStdDev > 0.25;
  }

  bool _hasStaleData({
    required ImuChunkEntity chunk,
    required List<TrackingPointEntity> recentGpsPoints,
  }) {
    if (recentGpsPoints.isEmpty) {
      return true;
    }
    final latestPoint = recentGpsPoints.first;
    return chunk.capturedAtUtc
            .difference(latestPoint.timestampUtc.toUtc())
            .inSeconds
            .abs() >
        30;
  }

  double? _resolveGpsCourseOverGroundDegrees(
    List<TrackingPointEntity> recentGpsPoints,
  ) {
    if (recentGpsPoints.length < 2) {
      return null;
    }

    final latest = recentGpsPoints.first;
    if ((latest.speedMetersPerSecond ?? 0) <= 2.5) {
      return null;
    }

    final previous = recentGpsPoints[1];
    final bearing = _bearingDegrees(
      previous.latitude,
      previous.longitude,
      latest.latitude,
      latest.longitude,
    );
    return _headingNormalizer.normalizeDegrees(bearing);
  }

  double _bearingDegrees(
    double fromLatitude,
    double fromLongitude,
    double toLatitude,
    double toLongitude,
  ) {
    final fromLat = _degreesToRadians(fromLatitude);
    final toLat = _degreesToRadians(toLatitude);
    final deltaLon = _degreesToRadians(toLongitude - fromLongitude);
    final y = math.sin(deltaLon) * math.cos(toLat);
    final x =
        (math.cos(fromLat) * math.sin(toLat)) -
        (math.sin(fromLat) * math.cos(toLat) * math.cos(deltaLon));
    return _headingNormalizer.normalizeDegrees(
      _radiansToDegrees(math.atan2(y, x)),
    );
  }

  double _vectorNorm(List<double> vector) {
    return math.sqrt(
      (vector[0] * vector[0]) +
          (vector[1] * vector[1]) +
          (vector[2] * vector[2]),
    );
  }

  double _degreesToRadians(double degrees) => degrees * 0.017453292519943295;

  double _radiansToDegrees(double radians) => radians * 57.29577951308232;
}

class ProcessedImuChunk {
  const ProcessedImuChunk({
    required this.nextState,
    required this.decodedEvents,
    required this.metrics,
  });

  final FusionSessionState nextState;
  final List<ImuSensorEventEntity> decodedEvents;
  final List<DerivedMetricEntity> metrics;
}
