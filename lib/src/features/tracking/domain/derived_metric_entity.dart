class DerivedMetricEntity {
  const DerivedMetricEntity({
    this.id,
    required this.sessionId,
    required this.timestampUtc,
    required this.metricType,
    required this.metricValue,
    this.unit,
  });

  final int? id;
  final int sessionId;
  final DateTime timestampUtc;
  final String metricType;
  final double metricValue;
  final String? unit;
}
