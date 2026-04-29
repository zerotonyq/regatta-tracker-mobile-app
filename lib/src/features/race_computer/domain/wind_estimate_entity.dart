class WindEstimateEntity {
  const WindEstimateEntity({
    required this.directionDegrees,
    required this.confidence,
    required this.source,
    this.qualityLabel,
  });

  final double directionDegrees;
  final double confidence;
  final String source;
  final String? qualityLabel;
}
