import 'sync_job_entity.dart';

abstract class SyncRepository {
  Future<void> enqueue(SyncJobEntity job);

  Future<List<SyncJobEntity>> getReadyJobs({
    DateTime? notBeforeUtc,
    int limit = 50,
  });

  Future<List<SyncJobEntity>> getPendingJobs();

  Future<List<SyncJobEntity>> getAllJobs();

  Future<void> markInProgress({
    required String jobId,
    required int attemptCount,
  });

  Future<void> markSynced({
    required String jobId,
    required DateTime syncedAtUtc,
  });

  Future<void> markFailedRetryable({
    required String jobId,
    required String lastError,
    required int attemptCount,
    required DateTime nextRetryAtUtc,
  });

  Future<void> markFailedTerminal({
    required String jobId,
    required String lastError,
    required int attemptCount,
  });

  Future<void> resetInProgressJobs();
}
