class TrackingPointEntity {
  const TrackingPointEntity({
    this.id,
    this.sessionId,
    required this.timestampUtc,
    required this.longitude,
    required this.latitude,
    this.accuracyMeters,
    this.speedMetersPerSecond,
  });

  final int? id;
  final int? sessionId;
  final DateTime timestampUtc;
  final double longitude;
  final double latitude;
  final double? accuracyMeters;
  final double? speedMetersPerSecond;

  TrackingPointEntity copyWith({
    int? id,
    int? sessionId,
    DateTime? timestampUtc,
    double? longitude,
    double? latitude,
    double? accuracyMeters,
    double? speedMetersPerSecond,
  }) {
    return TrackingPointEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      speedMetersPerSecond: speedMetersPerSecond ?? this.speedMetersPerSecond,
    );
  }
}
