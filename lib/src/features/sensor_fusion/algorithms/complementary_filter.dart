import 'dart:math' as math;

import '../application/heading_normalizer.dart';
import '../application/heel_estimator.dart';
import '../domain/derived_metrics_frame.dart';
import '../domain/fusion_quality_flag.dart';
import '../domain/fusion_session_state.dart';
import '../domain/imu_sensor_event_entity.dart';

class ComplementaryFilter {
  const ComplementaryFilter({
    HeadingNormalizer headingNormalizer = const HeadingNormalizer(),
    HeelEstimator heelEstimator = const HeelEstimator(),
    double pitchRollAlpha = 0.98,
    double yawAlpha = 0.96,
    double smoothedAccelerationAlpha = 0.90,
  }) : _headingNormalizer = headingNormalizer,
       _heelEstimator = heelEstimator,
       _pitchRollAlpha = pitchRollAlpha,
       _yawAlpha = yawAlpha,
       _smoothedAccelerationAlpha = smoothedAccelerationAlpha;

  final HeadingNormalizer _headingNormalizer;
  final HeelEstimator _heelEstimator;
  final double _pitchRollAlpha;
  final double _yawAlpha;
  final double _smoothedAccelerationAlpha;

  FilterChunkResult processChunk({
    required FusionSessionState initialState,
    required List<ImuSensorEventEntity> events,
    required DateTime timestampUtc,
    required double? gpsCourseOverGroundDegrees,
    required bool calibrationMissing,
    required bool magneticInstability,
    required bool staleData,
  }) {
    double roll = initialState.rollRad;
    double pitch = initialState.pitchRad;
    double yaw = initialState.yawRad;
    double smoothedAccel = initialState.smoothedAccelerationMetersPerSecond2;
    int? lastGyroTimestampNs = initialState.lastGyroTimestampNs;

    List<double>? latestAccel;
    List<double>? latestMag;
    double turnRateDegreesPerSecond = 0;
    int gyroscopeSamples = 0;
    final headingSamples = <double>[];

    for (final ImuSensorEventEntity event in events) {
      switch (event.sensorType) {
        case ImuSensorType.accelerometer:
          latestAccel = _removeBias(
            event.vector,
            initialState.accelerometerBias,
          );
        case ImuSensorType.magnetometer:
          latestMag = _removeBias(event.vector, initialState.magnetometerBias);
        case ImuSensorType.gyroscope:
          gyroscopeSamples += 1;
          final correctedGyro = _removeBias(
            event.vector,
            initialState.gyroscopeBias,
          );
          final dtSeconds = lastGyroTimestampNs == null
              ? 0.02
              : ((event.sensorTimestampNs - lastGyroTimestampNs) / 1e9).clamp(
                  0.001,
                  0.2,
                );
          lastGyroTimestampNs = event.sensorTimestampNs;

          roll += correctedGyro[0] * dtSeconds;
          pitch += correctedGyro[1] * dtSeconds;
          yaw += correctedGyro[2] * dtSeconds;

          if (latestAccel != null) {
            final accelRoll = math.atan2(latestAccel[1], latestAccel[2]);
            final accelPitch = math.atan2(
              -latestAccel[0],
              math.sqrt(
                latestAccel[1] * latestAccel[1] +
                    latestAccel[2] * latestAccel[2],
              ),
            );
            roll =
                (_pitchRollAlpha * roll) + ((1 - _pitchRollAlpha) * accelRoll);
            pitch =
                (_pitchRollAlpha * pitch) +
                ((1 - _pitchRollAlpha) * accelPitch);
            final accelNorm = math.sqrt(
              latestAccel[0] * latestAccel[0] +
                  latestAccel[1] * latestAccel[1] +
                  latestAccel[2] * latestAccel[2],
            );
            smoothedAccel =
                (_smoothedAccelerationAlpha * smoothedAccel) +
                ((1 - _smoothedAccelerationAlpha) * accelNorm);
          }

          if (latestMag != null) {
            final magHeading = _computeHeadingFromMagnetometer(
              roll: roll,
              pitch: pitch,
              magnetometer: latestMag,
            );
            yaw = (_yawAlpha * yaw) + ((1 - _yawAlpha) * magHeading);
          }

          turnRateDegreesPerSecond = correctedGyro[2] * 180.0 / math.pi;
          headingSamples.add(
            _headingNormalizer.radiansToNormalizedDegrees(yaw),
          );
        case ImuSensorType.unknown:
          continue;
      }
    }

    if (gpsCourseOverGroundDegrees != null && headingSamples.isNotEmpty) {
      final fusedHeading =
          (0.75 * headingSamples.last) + (0.25 * gpsCourseOverGroundDegrees);
      yaw = _degreesToRadians(
        _headingNormalizer.normalizeDegrees(fusedHeading),
      );
    }

    final rollDegrees = roll * 180.0 / math.pi;
    final pitchDegrees = pitch * 180.0 / math.pi;
    final yawDegrees = yaw * 180.0 / math.pi;
    final headingDegrees = _headingNormalizer.radiansToNormalizedDegrees(yaw);
    final flags = <FusionQualityFlag>{
      if (calibrationMissing) FusionQualityFlag.calibrationMissing,
      if (magneticInstability) FusionQualityFlag.magneticInstability,
      if (staleData) FusionQualityFlag.staleData,
      if (gyroscopeSamples < 4) FusionQualityFlag.insufficientSamples,
      if (gpsCourseOverGroundDegrees != null)
        FusionQualityFlag.headingValidatedByGps,
    };

    return FilterChunkResult(
      frame: DerivedMetricsFrame(
        timestampUtc: timestampUtc,
        rollDegrees: rollDegrees,
        pitchDegrees: pitchDegrees,
        yawDegrees: yawDegrees,
        headingDegrees: headingDegrees,
        heelDegrees: _heelEstimator.estimateDegrees(rollDegrees),
        turnRateDegreesPerSecond: turnRateDegreesPerSecond,
        smoothedAccelerationMetersPerSecond2: smoothedAccel,
        qualityFlags: flags,
      ),
      nextState: initialState.copyWith(
        rollRad: roll,
        pitchRad: pitch,
        yawRad: yaw,
        smoothedAccelerationMetersPerSecond2: smoothedAccel,
        lastGyroTimestampNs: lastGyroTimestampNs,
      ),
    );
  }

  double _computeHeadingFromMagnetometer({
    required double roll,
    required double pitch,
    required List<double> magnetometer,
  }) {
    final sinRoll = math.sin(roll);
    final cosRoll = math.cos(roll);
    final sinPitch = math.sin(pitch);
    final cosPitch = math.cos(pitch);

    final compensatedX =
        (magnetometer[0] * cosPitch) + (magnetometer[2] * sinPitch);
    final compensatedY =
        (magnetometer[0] * sinRoll * sinPitch) +
        (magnetometer[1] * cosRoll) -
        (magnetometer[2] * sinRoll * cosPitch);
    return math.atan2(-compensatedY, compensatedX);
  }

  List<double> _removeBias(List<double> vector, List<double> bias) {
    return <double>[
      vector[0] - bias[0],
      vector[1] - bias[1],
      vector[2] - bias[2],
    ];
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180.0;
}

class FilterChunkResult {
  const FilterChunkResult({required this.frame, required this.nextState});

  final DerivedMetricsFrame frame;
  final FusionSessionState nextState;
}
