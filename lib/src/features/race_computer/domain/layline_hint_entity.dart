class LaylineHintEntity {
  const LaylineHintEntity({
    required this.targetTack,
    required this.bearingDegrees,
    required this.confidence,
    this.explanation,
  });

  final String targetTack;
  final double bearingDegrees;
  final double confidence;
  final String? explanation;
}
