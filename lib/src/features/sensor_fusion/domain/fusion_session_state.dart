class FusionSessionState {
  const FusionSessionState({
    this.accelerometerBias = const <double>[0, 0, 0],
    this.gyroscopeBias = const <double>[0, 0, 0],
    this.magnetometerBias = const <double>[0, 0, 0],
    this.rollRad = 0,
    this.pitchRad = 0,
    this.yawRad = 0,
    this.smoothedAccelerationMetersPerSecond2 = 0,
    this.lastGyroTimestampNs,
    this.calibrationSampleCount = 0,
    this.hasCalibration = false,
  });

  final List<double> accelerometerBias;
  final List<double> gyroscopeBias;
  final List<double> magnetometerBias;
  final double rollRad;
  final double pitchRad;
  final double yawRad;
  final double smoothedAccelerationMetersPerSecond2;
  final int? lastGyroTimestampNs;
  final int calibrationSampleCount;
  final bool hasCalibration;

  FusionSessionState copyWith({
    List<double>? accelerometerBias,
    List<double>? gyroscopeBias,
    List<double>? magnetometerBias,
    double? rollRad,
    double? pitchRad,
    double? yawRad,
    double? smoothedAccelerationMetersPerSecond2,
    int? lastGyroTimestampNs,
    int? calibrationSampleCount,
    bool? hasCalibration,
  }) {
    return FusionSessionState(
      accelerometerBias: accelerometerBias ?? this.accelerometerBias,
      gyroscopeBias: gyroscopeBias ?? this.gyroscopeBias,
      magnetometerBias: magnetometerBias ?? this.magnetometerBias,
      rollRad: rollRad ?? this.rollRad,
      pitchRad: pitchRad ?? this.pitchRad,
      yawRad: yawRad ?? this.yawRad,
      smoothedAccelerationMetersPerSecond2:
          smoothedAccelerationMetersPerSecond2 ??
          this.smoothedAccelerationMetersPerSecond2,
      lastGyroTimestampNs: lastGyroTimestampNs ?? this.lastGyroTimestampNs,
      calibrationSampleCount:
          calibrationSampleCount ?? this.calibrationSampleCount,
      hasCalibration: hasCalibration ?? this.hasCalibration,
    );
  }
}
