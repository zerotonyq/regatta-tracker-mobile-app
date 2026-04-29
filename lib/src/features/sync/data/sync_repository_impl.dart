import '../../local_storage/database/app_database.dart';
import '../domain/sync_job_entity.dart';
import '../domain/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  const SyncRepositoryImpl(this._appDatabase);

  final AppDatabase _appDatabase;

  @override
  Future<void> enqueue(SyncJobEntity job) async {
    await _appDatabase.syncQueueDao.enqueue(job);
  }

  @override
  Future<List<SyncJobEntity>> getAllJobs() async =>
      _appDatabase.syncQueueDao.getAllJobs();

  @override
  Future<List<SyncJobEntity>> getPendingJobs() async =>
      _appDatabase.syncQueueDao.getPendingJobs();

  @override
  Future<List<SyncJobEntity>> getReadyJobs({
    DateTime? notBeforeUtc,
    int limit = 50,
  }) async => _appDatabase.syncQueueDao.getReadyJobs(
    notBeforeUtc: notBeforeUtc ?? DateTime.now().toUtc(),
    limit: limit,
  );

  @override
  Future<void> markFailedRetryable({
    required String jobId,
    required String lastError,
    required int attemptCount,
    required DateTime nextRetryAtUtc,
  }) {
    return _appDatabase.syncQueueDao.markFailedRetryable(
      jobId: jobId,
      lastError: lastError,
      attemptCount: attemptCount,
      nextRetryAtUtc: nextRetryAtUtc,
    );
  }

  @override
  Future<void> markFailedTerminal({
    required String jobId,
    required String lastError,
    required int attemptCount,
  }) {
    return _appDatabase.syncQueueDao.markFailedTerminal(
      jobId: jobId,
      lastError: lastError,
      attemptCount: attemptCount,
    );
  }

  @override
  Future<void> markInProgress({
    required String jobId,
    required int attemptCount,
  }) {
    return _appDatabase.syncQueueDao.markInProgress(
      jobId: jobId,
      attemptCount: attemptCount,
    );
  }

  @override
  Future<void> markSynced({
    required String jobId,
    required DateTime syncedAtUtc,
  }) {
    return _appDatabase.syncQueueDao.markSynced(
      jobId: jobId,
      syncedAtUtc: syncedAtUtc,
    );
  }

  @override
  Future<void> resetInProgressJobs() {
    return _appDatabase.syncQueueDao.resetInProgressJobs();
  }
}
