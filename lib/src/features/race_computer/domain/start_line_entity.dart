import 'geo_point_entity.dart';

class StartLineEntity {
  const StartLineEntity({
    required this.committeeBoat,
    required this.pinEnd,
    this.name = 'Start line',
  });

  final GeoPointEntity committeeBoat;
  final GeoPointEntity pinEnd;
  final String name;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'name': name,
      'committeeBoat': committeeBoat.toJson(),
      'pinEnd': pinEnd.toJson(),
    };
  }

  factory StartLineEntity.fromJson(Map<String, Object?> json) {
    return StartLineEntity(
      name: json['name'] as String? ?? 'Start line',
      committeeBoat: GeoPointEntity.fromJson(
        json['committeeBoat']! as Map<String, Object?>,
      ),
      pinEnd: GeoPointEntity.fromJson(json['pinEnd']! as Map<String, Object?>),
    );
  }
}
