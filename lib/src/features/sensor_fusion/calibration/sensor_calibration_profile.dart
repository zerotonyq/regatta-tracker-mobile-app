class SensorCalibrationProfile {
  const SensorCalibrationProfile({
    required this.name,
    required this.biasVector,
  });

  final String name;
  final List<double> biasVector;
}
