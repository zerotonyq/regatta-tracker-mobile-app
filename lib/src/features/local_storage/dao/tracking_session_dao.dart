part of '../database/app_database.dart';

@DriftAccessor(tables: [TrackingSessions])
class TrackingSessionDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingSessionDaoMixin {
  TrackingSessionDao(super.db);

  Future<TrackingSessionEntity> createSession({
    required int raceId,
    required String role,
    required int intervalSeconds,
    required TrackingSessionState state,
    String? sensorHealthSnapshot,
  }) async {
    final startedAtUtc = DateTime.now().toUtc();
    final id = await into(trackingSessions).insert(
      TrackingSessionsCompanion.insert(
        raceId: raceId,
        role: role,
        state: state.name,
        intervalSeconds: intervalSeconds,
        startedAtUtc: startedAtUtc,
        sensorHealthSnapshot: Value(sensorHealthSnapshot),
      ),
    );

    return TrackingSessionEntity(
      id: id,
      raceId: raceId,
      role: role,
      state: state,
      intervalSeconds: intervalSeconds,
      startedAtUtc: startedAtUtc,
      sensorHealthSnapshot: sensorHealthSnapshot,
    );
  }

  Future<void> transitionSessionState({
    required int sessionId,
    required TrackingSessionState state,
    DateTime? endedAtUtc,
    String? failureReason,
    DateTime? lastSyncAtUtc,
    String? sensorHealthSnapshot,
  }) {
    return (update(
      trackingSessions,
    )..where((tbl) => tbl.id.equals(sessionId))).write(
      TrackingSessionsCompanion(
        state: Value(state.name),
        endedAtUtc: Value(endedAtUtc),
        failureReason: Value(failureReason),
        lastSyncAtUtc: Value(lastSyncAtUtc),
        sensorHealthSnapshot: Value(sensorHealthSnapshot),
      ),
    );
  }

  Future<TrackingSessionEntity?> loadLatestUnfinishedSession() async {
    final row =
        await (select(trackingSessions)
              ..where(
                (tbl) => tbl.state.isIn(const <String>[
                  'preparing',
                  'tracking',
                  'paused',
                  'syncing',
                ]),
              )
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.startedAtUtc,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _mapRow(row);
  }

  Future<TrackingSessionEntity?> loadSessionById(int sessionId) async {
    final row = await (select(
      trackingSessions,
    )..where((tbl) => tbl.id.equals(sessionId))).getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _mapRow(row);
  }

  Future<List<TrackingSessionEntity>> loadCompletedSessions({
    int limit = 50,
  }) async {
    final rows =
        await (select(trackingSessions)
              ..where(
                (tbl) => tbl.state.isIn(const <String>['completed', 'failed']),
              )
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.startedAtUtc,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();

    return rows.map(_mapRow).toList(growable: false);
  }

  TrackingSessionEntity _mapRow(TrackingSession row) {
    return TrackingSessionEntity(
      id: row.id,
      raceId: row.raceId,
      role: row.role,
      state: trackingSessionStateFromDb(row.state),
      intervalSeconds: row.intervalSeconds,
      startedAtUtc: row.startedAtUtc,
      endedAtUtc: row.endedAtUtc,
      failureReason: row.failureReason,
      lastSyncAtUtc: row.lastSyncAtUtc,
      sensorHealthSnapshot: row.sensorHealthSnapshot,
    );
  }
}
