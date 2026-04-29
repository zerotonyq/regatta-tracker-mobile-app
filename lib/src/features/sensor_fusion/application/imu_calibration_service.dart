import 'dart:math' as math;

import '../domain/fusion_session_state.dart';
import '../domain/imu_sensor_event_entity.dart';

class ImuCalibrationService {
  const ImuCalibrationService();

  static const int minimumCalibrationSamples = 12;
  static const double gravityMetersPerSecond2 = 9.80665;

  FusionSessionState updateCalibration({
    required FusionSessionState currentState,
    required List<ImuSensorEventEntity> events,
  }) {
    final accelerometerEvents = events
        .where((ImuSensorEventEntity event) {
          return event.sensorType == ImuSensorType.accelerometer;
        })
        .toList(growable: false);
    final gyroscopeEvents = events
        .where((ImuSensorEventEntity event) {
          return event.sensorType == ImuSensorType.gyroscope;
        })
        .toList(growable: false);
    final magnetometerEvents = events
        .where((ImuSensorEventEntity event) {
          return event.sensorType == ImuSensorType.magnetometer;
        })
        .toList(growable: false);

    final calibrationSamples = math.min(
      accelerometerEvents.length,
      gyroscopeEvents.length,
    );
    if (calibrationSamples < minimumCalibrationSamples) {
      return currentState.copyWith(
        calibrationSampleCount:
            currentState.calibrationSampleCount + calibrationSamples,
      );
    }

    final accelMean = _meanVector(accelerometerEvents);
    final gyroMean = _meanVector(gyroscopeEvents);
    final magnetometerMean = magnetometerEvents.isEmpty
        ? currentState.magnetometerBias
        : _meanVector(magnetometerEvents);

    final accelBias = <double>[
      accelMean[0],
      accelMean[1],
      accelMean[2] - gravityMetersPerSecond2,
    ];

    return currentState.copyWith(
      accelerometerBias: accelBias,
      gyroscopeBias: gyroMean,
      magnetometerBias: magnetometerMean,
      calibrationSampleCount:
          currentState.calibrationSampleCount + calibrationSamples,
      hasCalibration: true,
    );
  }

  List<double> _meanVector(List<ImuSensorEventEntity> events) {
    if (events.isEmpty) {
      return const <double>[0, 0, 0];
    }

    double sumX = 0;
    double sumY = 0;
    double sumZ = 0;
    for (final ImuSensorEventEntity event in events) {
      sumX += event.x;
      sumY += event.y;
      sumZ += event.z;
    }
    return <double>[
      sumX / events.length,
      sumY / events.length,
      sumZ / events.length,
    ];
  }
}
