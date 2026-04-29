part of '../database/app_database.dart';

@DriftAccessor(tables: [GpsPoints])
class TrackingPointDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingPointDaoMixin {
  TrackingPointDao(super.db);

  Future<void> insertPoint(TrackingPointEntity point) async {
    await into(gpsPoints).insert(
      GpsPointsCompanion.insert(
        sessionId: point.sessionId!,
        timestampUtc: point.timestampUtc,
        longitude: point.longitude,
        latitude: point.latitude,
        accuracyMeters: Value(point.accuracyMeters),
        speedMetersPerSecond: Value(point.speedMetersPerSecond),
      ),
    );
  }

  Future<List<TrackingPointEntity>> loadPointsForSession(int sessionId) async {
    final rows =
        await (select(gpsPoints)
              ..where((tbl) => tbl.sessionId.equals(sessionId))
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.timestampUtc,
                  mode: OrderingMode.asc,
                ),
              ]))
            .get();

    return rows
        .map(
          (row) => TrackingPointEntity(
            id: row.id,
            sessionId: row.sessionId,
            timestampUtc: row.timestampUtc,
            longitude: row.longitude,
            latitude: row.latitude,
            accuracyMeters: row.accuracyMeters,
            speedMetersPerSecond: row.speedMetersPerSecond,
          ),
        )
        .toList(growable: false);
  }

  Future<TrackingPointEntity?> loadLatestPointForSession(int sessionId) async {
    final row =
        await (select(gpsPoints)
              ..where((tbl) => tbl.sessionId.equals(sessionId))
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.timestampUtc,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return TrackingPointEntity(
      id: row.id,
      sessionId: row.sessionId,
      timestampUtc: row.timestampUtc,
      longitude: row.longitude,
      latitude: row.latitude,
      accuracyMeters: row.accuracyMeters,
      speedMetersPerSecond: row.speedMetersPerSecond,
    );
  }

  Future<List<TrackingPointEntity>> loadRecentPointsForSession(
    int sessionId, {
    int limit = 2,
  }) async {
    final rows =
        await (select(gpsPoints)
              ..where((tbl) => tbl.sessionId.equals(sessionId))
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.timestampUtc,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();

    return rows
        .map(
          (GpsPoint row) => TrackingPointEntity(
            id: row.id,
            sessionId: row.sessionId,
            timestampUtc: row.timestampUtc,
            longitude: row.longitude,
            latitude: row.latitude,
            accuracyMeters: row.accuracyMeters,
            speedMetersPerSecond: row.speedMetersPerSecond,
          ),
        )
        .toList(growable: false);
  }

  Future<int> countPointsForSession(int sessionId) async {
    final countExpression = gpsPoints.id.count();
    final row = await (selectOnly(gpsPoints)
          ..addColumns([countExpression])
          ..where(gpsPoints.sessionId.equals(sessionId)))
        .getSingle();
    return row.read(countExpression) ?? 0;
  }
}
