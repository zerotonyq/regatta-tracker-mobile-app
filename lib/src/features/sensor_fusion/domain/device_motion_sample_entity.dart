class DeviceMotionSampleEntity {
  const DeviceMotionSampleEntity({
    required this.timestampUtc,
    required this.accelerometer,
    required this.gyroscope,
  });

  final DateTime timestampUtc;
  final List<double> accelerometer;
  final List<double> gyroscope;
}
