class MarkSnapshotEntity {
  const MarkSnapshotEntity({
    required this.markName,
    required this.distanceMeters,
    required this.bearingDegrees,
    this.etaSeconds,
  });

  final String markName;
  final double distanceMeters;
  final double bearingDegrees;
  final int? etaSeconds;
}
