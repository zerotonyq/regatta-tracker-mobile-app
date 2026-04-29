enum ImuSensorType { accelerometer, magnetometer, gyroscope, unknown }

class ImuSensorEventEntity {
  const ImuSensorEventEntity({
    required this.sensorType,
    required this.sensorTimestampNs,
    required this.x,
    required this.y,
    required this.z,
    required this.accuracy,
  });

  final ImuSensorType sensorType;
  final int sensorTimestampNs;
  final double x;
  final double y;
  final double z;
  final int accuracy;

  List<double> get vector => <double>[x, y, z];
}
