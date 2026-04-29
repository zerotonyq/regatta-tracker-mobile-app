import 'fusion_quality_flag.dart';

class DerivedMetricsFrame {
  const DerivedMetricsFrame({
    required this.timestampUtc,
    required this.rollDegrees,
    required this.pitchDegrees,
    required this.yawDegrees,
    required this.headingDegrees,
    required this.heelDegrees,
    required this.turnRateDegreesPerSecond,
    required this.smoothedAccelerationMetersPerSecond2,
    required this.qualityFlags,
  });

  final DateTime timestampUtc;
  final double rollDegrees;
  final double pitchDegrees;
  final double yawDegrees;
  final double headingDegrees;
  final double heelDegrees;
  final double turnRateDegreesPerSecond;
  final double smoothedAccelerationMetersPerSecond2;
  final Set<FusionQualityFlag> qualityFlags;
}
