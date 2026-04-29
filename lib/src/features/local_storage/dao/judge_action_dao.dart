part of '../database/app_database.dart';

@DriftAccessor(tables: [JudgeActions])
class JudgeActionDao extends DatabaseAccessor<AppDatabase>
    with _$JudgeActionDaoMixin {
  JudgeActionDao(super.db);

  Future<void> insertAction(JudgeActionEntity action) async {
    await into(judgeActions).insert(
      JudgeActionsCompanion.insert(
        raceId: Value(action.raceId),
        actionType: action.eventType,
        payloadJson: action.payloadJson ?? '{}',
        occurredAtUtc: action.createdAtUtc,
        syncState: Value(action.syncStatus),
      ),
    );
  }

  Future<List<JudgeActionEntity>> loadRecentActions({int limit = 20}) async {
    final rows =
        await (select(judgeActions)
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.occurredAtUtc,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();
    return _mapRows(rows);
  }

  Future<List<JudgeActionEntity>> loadActionsForRace({
    required int raceId,
    int limit = 50,
  }) async {
    final rows =
        await (select(judgeActions)
              ..where((tbl) => tbl.raceId.equals(raceId))
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.occurredAtUtc,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();

    return _mapRows(rows);
  }

  List<JudgeActionEntity> _mapRows(List<JudgeAction> rows) {
    return rows
        .map(
          (row) => JudgeActionEntity(
            eventId: 'judge-action-${row.id}',
            raceId: row.raceId,
            eventType: row.actionType,
            payloadJson: row.payloadJson,
            createdAtUtc: row.occurredAtUtc,
            syncStatus: row.syncState,
          ),
        )
        .toList(growable: false);
  }
}
