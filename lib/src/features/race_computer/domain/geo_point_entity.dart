class GeoPointEntity {
  const GeoPointEntity({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  Map<String, Object?> toJson() {
    return <String, Object?>{'latitude': latitude, 'longitude': longitude};
  }

  factory GeoPointEntity.fromJson(Map<String, Object?> json) {
    return GeoPointEntity(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
