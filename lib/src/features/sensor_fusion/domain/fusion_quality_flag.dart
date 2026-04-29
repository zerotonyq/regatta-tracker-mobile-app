enum FusionQualityFlag {
  insufficientSamples,
  magneticInstability,
  calibrationMissing,
  staleData,
  headingValidatedByGps,
}

extension FusionQualityFlagMetric on FusionQualityFlag {
  String get metricType => switch (this) {
    FusionQualityFlag.insufficientSamples => 'quality_insufficient_samples',
    FusionQualityFlag.magneticInstability => 'quality_magnetic_instability',
    FusionQualityFlag.calibrationMissing => 'quality_calibration_missing',
    FusionQualityFlag.staleData => 'quality_stale_data',
    FusionQualityFlag.headingValidatedByGps =>
      'quality_heading_validated_by_gps',
  };
}
