import 'mark_entity.dart';
import 'start_line_entity.dart';

class CourseEntity {
  const CourseEntity({
    required this.raceId,
    required this.name,
    required this.startLine,
    required this.marks,
    required this.finishLine,
    required this.updatedAtUtc,
    this.version = 1,
    this.source = 'local_reference',
  });

  final int raceId;
  final String name;
  final StartLineEntity startLine;
  final List<MarkEntity> marks;
  final StartLineEntity finishLine;
  final DateTime updatedAtUtc;
  final int version;
  final String source;

  MarkEntity? get nextMark => marks.isEmpty ? null : marks.first;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'raceId': raceId,
      'name': name,
      'startLine': startLine.toJson(),
      'marks': marks.map((MarkEntity mark) => mark.toJson()).toList(),
      'finishLine': finishLine.toJson(),
      'updatedAtUtc': updatedAtUtc.toIso8601String(),
      'version': version,
      'source': source,
    };
  }

  factory CourseEntity.fromJson(Map<String, Object?> json) {
    return CourseEntity(
      raceId: (json['raceId'] as num).toInt(),
      name: json['name'] as String,
      startLine: StartLineEntity.fromJson(
        json['startLine']! as Map<String, Object?>,
      ),
      marks: (json['marks'] as List<Object?>? ?? const <Object?>[])
          .map((Object? item) {
            return MarkEntity.fromJson(item! as Map<String, Object?>);
          })
          .toList(growable: false),
      finishLine: StartLineEntity.fromJson(
        (json['finishLine'] ??
                json['startLine'])! as Map<String, Object?>,
      ),
      updatedAtUtc: DateTime.parse(json['updatedAtUtc'] as String).toUtc(),
      version: (json['version'] as num?)?.toInt() ?? 1,
      source: json['source'] as String? ?? 'local_reference',
    );
  }
}
