import 'geo_point_entity.dart';

class MarkEntity {
  const MarkEntity({
    required this.id,
    required this.name,
    required this.position,
    required this.order,
  });

  final String id;
  final String name;
  final GeoPointEntity position;
  final int order;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'position': position.toJson(),
      'order': order,
    };
  }

  factory MarkEntity.fromJson(Map<String, Object?> json) {
    return MarkEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      position: GeoPointEntity.fromJson(
        json['position']! as Map<String, Object?>,
      ),
      order: (json['order'] as num).toInt(),
    );
  }
}
