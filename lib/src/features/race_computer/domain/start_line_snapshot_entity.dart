class StartLineSnapshotEntity {
  const StartLineSnapshotEntity({
    required this.distanceToLineMeters,
    required this.crossedLine,
    required this.favoredEnd,
    required this.favoredEndBiasDegrees,
    required this.lineBearingDegrees,
    required this.lateralOffsetMeters,
    required this.lineClosingSpeedMetersPerSecond,
  });

  final double distanceToLineMeters;
  final bool crossedLine;
  final String favoredEnd;
  final double favoredEndBiasDegrees;
  final double lineBearingDegrees;
  final double lateralOffsetMeters;
  final double lineClosingSpeedMetersPerSecond;
}
