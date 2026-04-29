part of '../database/app_database.dart';

@DriftAccessor(tables: [CourseDefinitions])
class CourseDefinitionDao extends DatabaseAccessor<AppDatabase>
    with _$CourseDefinitionDaoMixin {
  CourseDefinitionDao(super.db);

  Future<void> upsertCourseDefinition({
    required int raceId,
    required String name,
    required String payloadJson,
    required DateTime updatedAtUtc,
    int version = 1,
  }) async {
    final existing =
        await (select(courseDefinitions)
              ..where((tbl) => tbl.raceId.equals(raceId))
              ..limit(1))
            .getSingleOrNull();

    if (existing == null) {
      await into(courseDefinitions).insert(
        CourseDefinitionsCompanion.insert(
          raceId: Value(raceId),
          name: name,
          payloadJson: payloadJson,
          updatedAtUtc: updatedAtUtc,
          version: Value(version),
        ),
      );
      return;
    }

    await (update(
      courseDefinitions,
    )..where((tbl) => tbl.id.equals(existing.id))).write(
      CourseDefinitionsCompanion(
        raceId: Value(raceId),
        name: Value(name),
        payloadJson: Value(payloadJson),
        updatedAtUtc: Value(updatedAtUtc),
        version: Value(version),
      ),
    );
  }

  Future<CourseDefinition?> loadCourseDefinition(int raceId) {
    return (select(courseDefinitions)
          ..where((tbl) => tbl.raceId.equals(raceId))
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.updatedAtUtc,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }
}
