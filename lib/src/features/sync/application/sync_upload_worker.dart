import 'dart:async';

import '../domain/connectivity_monitor.dart';
import '../domain/sync_clock.dart';
import '../domain/sync_batch_task_executor.dart';
import '../domain/sync_job_entity.dart';
import '../domain/sync_job_state.dart';
import '../domain/sync_repository.dart';
import '../domain/sync_task_executor.dart';
import '../domain/sync_task_result.dart';

class SyncUploadWorker {
  SyncUploadWorker({
    required SyncRepository syncRepository,
    required SyncTaskExecutor taskExecutor,
    required ConnectivityMonitor connectivityMonitor,
    SyncClock clock = const SyncClock(),
    Duration maxBackoff = const Duration(minutes: 5),
  }) : _syncRepository = syncRepository,
       _taskExecutor = taskExecutor,
       _connectivityMonitor = connectivityMonitor,
       _clock = clock,
       _maxBackoff = maxBackoff;

  final SyncRepository _syncRepository;
  final SyncTaskExecutor _taskExecutor;
  final ConnectivityMonitor _connectivityMonitor;
  final SyncClock _clock;
  final Duration _maxBackoff;

  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _retryTimer;
  bool _started = false;
  bool _running = false;
  bool _hasQueuedRun = false;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    await _syncRepository.resetInProgressJobs();
    _connectivitySubscription = _connectivityMonitor.watchStatus().listen((
      bool isOnline,
    ) {
      if (isOnline) {
        triggerNow();
      }
    });
    await triggerNow();
  }

  Future<void> dispose() async {
    _retryTimer?.cancel();
    await _connectivitySubscription?.cancel();
  }

  Future<void> triggerNow() async {
    _retryTimer?.cancel();
    if (_running) {
      _hasQueuedRun = true;
      return;
    }

    _running = true;
    try {
      do {
        _hasQueuedRun = false;
        await _drainQueue();
      } while (_hasQueuedRun);
    } finally {
      _running = false;
    }
  }

  Future<void> _drainQueue() async {
    if (!await _connectivityMonitor.isOnline()) {
      _scheduleRetry(const Duration(seconds: 15));
      return;
    }

    final jobs = await _syncRepository.getReadyJobs(
      notBeforeUtc: _clock.nowUtc(),
      limit: 50,
    );
    if (jobs.isEmpty) {
      return;
    }

    Duration? earliestRetryDelay;

    if (_taskExecutor is SyncBatchTaskExecutor) {
      final inProgressJobs = <SyncJobEntity>[];
      for (final SyncJobEntity job in jobs) {
        await _syncRepository.markInProgress(
          jobId: job.id,
          attemptCount: job.attemptCount + 1,
        );
        inProgressJobs.add(
          job.copyWith(
            state: SyncJobState.inProgress.wireName,
            attemptCount: job.attemptCount + 1,
          ),
        );
      }

      final results = await (_taskExecutor as SyncBatchTaskExecutor)
          .executeBatch(inProgressJobs);
      for (final SyncJobEntity job in jobs) {
        final result =
            results[job.id] ??
            const SyncTaskResult.retryableFailure(
              'Batch sync did not return a result for this job.',
            );
        earliestRetryDelay = await _applyResult(
          job: job,
          result: result,
          earliestRetryDelay: earliestRetryDelay,
        );
      }
    } else {
      for (final SyncJobEntity job in jobs) {
        await _syncRepository.markInProgress(
          jobId: job.id,
          attemptCount: job.attemptCount + 1,
        );

        final SyncTaskResult result = await _taskExecutor.execute(
          job.copyWith(
            state: SyncJobState.inProgress.wireName,
            attemptCount: job.attemptCount + 1,
          ),
        );

        earliestRetryDelay = await _applyResult(
          job: job,
          result: result,
          earliestRetryDelay: earliestRetryDelay,
        );
      }
    }

    final remainingReadyJobs = await _syncRepository.getReadyJobs(
      notBeforeUtc: _clock.nowUtc(),
      limit: 1,
    );
    if (remainingReadyJobs.isNotEmpty) {
      _hasQueuedRun = true;
      return;
    }

    if (earliestRetryDelay != null) {
      _scheduleRetry(earliestRetryDelay);
    }
  }

  Future<Duration?> _applyResult({
    required SyncJobEntity job,
    required SyncTaskResult result,
    required Duration? earliestRetryDelay,
  }) async {
    switch (result.type) {
      case SyncTaskResultType.synced:
        await _syncRepository.markSynced(
          jobId: job.id,
          syncedAtUtc: _clock.nowUtc(),
        );
        return earliestRetryDelay;
      case SyncTaskResultType.retryableFailure:
        final delay = _retryDelayForAttempt(job.attemptCount + 1);
        final nextRetryAt = _clock.nowUtc().add(delay);
        await _syncRepository.markFailedRetryable(
          jobId: job.id,
          lastError: result.message ?? 'Retryable sync failure.',
          attemptCount: job.attemptCount + 1,
          nextRetryAtUtc: nextRetryAt,
        );
        return _earliestDelay(earliestRetryDelay, delay);
      case SyncTaskResultType.terminalFailure:
        await _syncRepository.markFailedTerminal(
          jobId: job.id,
          lastError: result.message ?? 'Terminal sync failure.',
          attemptCount: job.attemptCount + 1,
        );
        return earliestRetryDelay;
    }
  }

  Duration _retryDelayForAttempt(int attemptCount) {
    final exponent = attemptCount <= 1 ? 0 : attemptCount - 1;
    final seconds = 5 * (1 << exponent);
    final delay = Duration(seconds: seconds);
    if (delay > _maxBackoff) {
      return _maxBackoff;
    }
    return delay;
  }

  Duration _earliestDelay(Duration? current, Duration candidate) {
    if (current == null || candidate < current) {
      return candidate;
    }
    return current;
  }

  void _scheduleRetry(Duration delay) {
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      unawaited(triggerNow());
    });
  }
}
