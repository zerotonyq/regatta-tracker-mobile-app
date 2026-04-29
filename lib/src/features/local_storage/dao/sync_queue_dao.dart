part of '../database/app_database.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<void> enqueue(SyncJobEntity job) async {
    await into(syncQueue).insert(
      SyncQueueCompanion.insert(
        id: job.id,
        jobType: job.type,
        state: job.state,
        createdAtUtc: job.createdAtUtc,
        availableAtUtc: job.availableAtUtc,
        sessionId: Value(job.sessionId),
        payloadJson: Value(job.payloadJson),
        attemptCount: Value(job.attemptCount),
        lastError: Value(job.lastError),
        priority: Value(job.priority),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<SyncJobEntity>> getAllJobs() async {
    final rows =
        await (select(syncQueue)..orderBy([
              (tbl) => OrderingTerm(
                expression: tbl.priority,
                mode: OrderingMode.asc,
              ),
              (tbl) => OrderingTerm(
                expression: tbl.createdAtUtc,
                mode: OrderingMode.asc,
              ),
            ]))
            .get();

    return rows.map(_mapRow).toList(growable: false);
  }

  Future<List<SyncJobEntity>> getPendingJobs() async {
    final rows =
        await (select(syncQueue)
              ..where(
                (tbl) => tbl.state.isIn(const <String>[
                  'pending',
                  'in_progress',
                  'failed_retryable',
                ]),
              )
              ..orderBy(_defaultOrder))
            .get();

    return rows.map(_mapRow).toList(growable: false);
  }

  Future<List<SyncJobEntity>> getReadyJobs({
    required DateTime notBeforeUtc,
    required int limit,
  }) async {
    final rows =
        await (select(syncQueue)
              ..where(
                (tbl) =>
                    tbl.state.isIn(const <String>[
                      'pending',
                      'failed_retryable',
                    ]) &
                    tbl.availableAtUtc.isSmallerOrEqualValue(notBeforeUtc),
              )
              ..orderBy(_defaultOrder)
              ..limit(limit))
            .get();

    return rows.map(_mapRow).toList(growable: false);
  }

  Future<void> markInProgress({
    required String jobId,
    required int attemptCount,
  }) async {
    await (update(syncQueue)..where((tbl) => tbl.id.equals(jobId))).write(
      SyncQueueCompanion(
        state: const Value('in_progress'),
        attemptCount: Value(attemptCount),
        lastError: const Value(null),
      ),
    );
  }

  Future<void> markSynced({
    required String jobId,
    required DateTime syncedAtUtc,
  }) async {
    await (update(syncQueue)..where((tbl) => tbl.id.equals(jobId))).write(
      SyncQueueCompanion(
        state: const Value('synced'),
        availableAtUtc: Value(syncedAtUtc),
        lastError: const Value(null),
      ),
    );
  }

  Future<void> markFailedRetryable({
    required String jobId,
    required String lastError,
    required int attemptCount,
    required DateTime nextRetryAtUtc,
  }) async {
    await (update(syncQueue)..where((tbl) => tbl.id.equals(jobId))).write(
      SyncQueueCompanion(
        state: const Value('failed_retryable'),
        lastError: Value(lastError),
        attemptCount: Value(attemptCount),
        availableAtUtc: Value(nextRetryAtUtc),
      ),
    );
  }

  Future<void> markFailedTerminal({
    required String jobId,
    required String lastError,
    required int attemptCount,
  }) async {
    await (update(syncQueue)..where((tbl) => tbl.id.equals(jobId))).write(
      SyncQueueCompanion(
        state: const Value('failed_terminal'),
        lastError: Value(lastError),
        attemptCount: Value(attemptCount),
      ),
    );
  }

  Future<void> resetInProgressJobs() async {
    await (update(syncQueue)..where((tbl) => tbl.state.equals('in_progress')))
        .write(const SyncQueueCompanion(state: Value('pending')));
  }

  List<OrderingTerm Function($SyncQueueTable)> get _defaultOrder =>
      <OrderingTerm Function($SyncQueueTable)>[
        (tbl) => OrderingTerm(expression: tbl.priority, mode: OrderingMode.asc),
        (tbl) => OrderingTerm(
          expression: tbl.availableAtUtc,
          mode: OrderingMode.asc,
        ),
        (tbl) =>
            OrderingTerm(expression: tbl.createdAtUtc, mode: OrderingMode.asc),
      ];

  SyncJobEntity _mapRow(SyncQueueData row) {
    return SyncJobEntity(
      id: row.id,
      type: row.jobType,
      state: row.state,
      createdAtUtc: row.createdAtUtc,
      availableAtUtc: row.availableAtUtc,
      sessionId: row.sessionId,
      payloadJson: row.payloadJson,
      attemptCount: row.attemptCount,
      lastError: row.lastError,
      priority: row.priority,
    );
  }

  Future<List<SyncJobEntity>> getJobsForSession(int sessionId) async {
    final rows =
        await (select(syncQueue)
              ..where((tbl) => tbl.sessionId.equals(sessionId))
              ..orderBy(_defaultOrder))
            .get();
    return rows.map(_mapRow).toList(growable: false);
  }
}
