import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/features/sync/application/sync_upload_worker.dart';
import 'package:vkr_regatta/src/features/sync/domain/connectivity_monitor.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_clock.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_job_entity.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_job_state.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_repository.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_task_executor.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_task_result.dart';

void main() {
  test('worker marks job synced after successful upload', () async {
    final repository = _FakeSyncRepository(
      jobs: <SyncJobEntity>[_job(state: SyncJobState.pending)],
    );
    final monitor = _FakeConnectivityMonitor(initialOnline: true);
    final executor = _FakeSyncTaskExecutor(
      results: <SyncTaskResult>[const SyncTaskResult.synced()],
    );
    final worker = SyncUploadWorker(
      syncRepository: repository,
      taskExecutor: executor,
      connectivityMonitor: monitor,
      clock: _FixedSyncClock(),
    );

    await worker.start();

    expect(repository.jobs.single.state, SyncJobState.synced.wireName);
    expect(repository.jobs.single.attemptCount, 1);
    await worker.dispose();
  });

  test(
    'worker keeps collecting tasks offline and drains after network returns',
    () async {
      final repository = _FakeSyncRepository(
        jobs: <SyncJobEntity>[_job(state: SyncJobState.pending)],
      );
      final monitor = _FakeConnectivityMonitor(initialOnline: false);
      final executor = _FakeSyncTaskExecutor(
        results: <SyncTaskResult>[const SyncTaskResult.synced()],
      );
      final worker = SyncUploadWorker(
        syncRepository: repository,
        taskExecutor: executor,
        connectivityMonitor: monitor,
        clock: _FixedSyncClock(),
      );

      await worker.start();
      expect(repository.jobs.single.state, SyncJobState.pending.wireName);

      monitor.setOnline(true);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.jobs.single.state, SyncJobState.synced.wireName);
      await worker.dispose();
    },
  );

  test('worker marks retryable failures with backoff', () async {
    final repository = _FakeSyncRepository(
      jobs: <SyncJobEntity>[_job(state: SyncJobState.pending)],
    );
    final monitor = _FakeConnectivityMonitor(initialOnline: true);
    final executor = _FakeSyncTaskExecutor(
      results: <SyncTaskResult>[
        const SyncTaskResult.retryableFailure('timeout'),
      ],
    );
    final worker = SyncUploadWorker(
      syncRepository: repository,
      taskExecutor: executor,
      connectivityMonitor: monitor,
      clock: _FixedSyncClock(),
    );

    await worker.start();

    expect(repository.jobs.single.state, SyncJobState.failedRetryable.wireName);
    expect(repository.jobs.single.attemptCount, 1);
    expect(
      repository.jobs.single.availableAtUtc,
      DateTime.utc(2026, 4, 29, 12, 0, 5),
    );
    await worker.dispose();
  });

  test('worker marks terminal failures without retry', () async {
    final repository = _FakeSyncRepository(
      jobs: <SyncJobEntity>[_job(state: SyncJobState.pending)],
    );
    final monitor = _FakeConnectivityMonitor(initialOnline: true);
    final executor = _FakeSyncTaskExecutor(
      results: <SyncTaskResult>[
        const SyncTaskResult.terminalFailure('403 forbidden'),
      ],
    );
    final worker = SyncUploadWorker(
      syncRepository: repository,
      taskExecutor: executor,
      connectivityMonitor: monitor,
      clock: _FixedSyncClock(),
    );

    await worker.start();

    expect(repository.jobs.single.state, SyncJobState.failedTerminal.wireName);
    await worker.dispose();
  });

  test('worker resets abandoned in_progress jobs on startup', () async {
    final repository = _FakeSyncRepository(
      jobs: <SyncJobEntity>[_job(state: SyncJobState.inProgress)],
    );
    final monitor = _FakeConnectivityMonitor(initialOnline: false);
    final executor = _FakeSyncTaskExecutor(results: const <SyncTaskResult>[]);
    final worker = SyncUploadWorker(
      syncRepository: repository,
      taskExecutor: executor,
      connectivityMonitor: monitor,
      clock: _FixedSyncClock(),
    );

    await worker.start();

    expect(repository.jobs.single.state, SyncJobState.pending.wireName);
    await worker.dispose();
  });
}

SyncJobEntity _job({required SyncJobState state}) {
  return SyncJobEntity(
    id: 'gps-1-100',
    type: 'gps_point_upload',
    state: state.wireName,
    createdAtUtc: DateTime.utc(2026, 4, 29, 12, 0, 0),
    availableAtUtc: DateTime.utc(2026, 4, 29, 12, 0, 0),
    sessionId: 1,
    payloadJson:
        '{"client_task_id":"gps-1-100","session_id":1,"timestamp_utc":"2026-04-29T12:00:00.000Z","longitude":30.1,"latitude":59.9}',
    priority: 50,
  );
}

class _FakeConnectivityMonitor implements ConnectivityMonitor {
  _FakeConnectivityMonitor({required bool initialOnline})
    : _online = initialOnline;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _online;

  @override
  Future<bool> isOnline() async => _online;

  void setOnline(bool online) {
    _online = online;
    _controller.add(online);
  }

  @override
  Stream<bool> watchStatus() => _controller.stream;
}

class _FakeSyncRepository implements SyncRepository {
  _FakeSyncRepository({required List<SyncJobEntity> jobs})
    : jobs = List<SyncJobEntity>.from(jobs);

  final List<SyncJobEntity> jobs;

  @override
  Future<void> enqueue(SyncJobEntity job) async {
    jobs.removeWhere((SyncJobEntity existing) => existing.id == job.id);
    jobs.add(job);
  }

  @override
  Future<List<SyncJobEntity>> getAllJobs() async =>
      List<SyncJobEntity>.from(jobs);

  @override
  Future<List<SyncJobEntity>> getPendingJobs() async {
    return jobs
        .where((SyncJobEntity job) => job.parsedState != SyncJobState.synced)
        .toList(growable: false);
  }

  @override
  Future<List<SyncJobEntity>> getReadyJobs({
    DateTime? notBeforeUtc,
    int limit = 50,
  }) async {
    final deadline = notBeforeUtc ?? DateTime.now().toUtc();
    return jobs
        .where(
          (SyncJobEntity job) =>
              (job.parsedState == SyncJobState.pending ||
                  job.parsedState == SyncJobState.failedRetryable) &&
              !job.availableAtUtc.isAfter(deadline),
        )
        .take(limit)
        .toList(growable: false);
  }

  @override
  Future<void> markFailedRetryable({
    required String jobId,
    required String lastError,
    required int attemptCount,
    required DateTime nextRetryAtUtc,
  }) async {
    _replace(
      jobId,
      (SyncJobEntity job) => job.copyWith(
        state: SyncJobState.failedRetryable.wireName,
        lastError: lastError,
        attemptCount: attemptCount,
        availableAtUtc: nextRetryAtUtc,
      ),
    );
  }

  @override
  Future<void> markFailedTerminal({
    required String jobId,
    required String lastError,
    required int attemptCount,
  }) async {
    _replace(
      jobId,
      (SyncJobEntity job) => job.copyWith(
        state: SyncJobState.failedTerminal.wireName,
        lastError: lastError,
        attemptCount: attemptCount,
      ),
    );
  }

  @override
  Future<void> markInProgress({
    required String jobId,
    required int attemptCount,
  }) async {
    _replace(
      jobId,
      (SyncJobEntity job) => job.copyWith(
        state: SyncJobState.inProgress.wireName,
        attemptCount: attemptCount,
        lastError: null,
      ),
    );
  }

  @override
  Future<void> markSynced({
    required String jobId,
    required DateTime syncedAtUtc,
  }) async {
    _replace(
      jobId,
      (SyncJobEntity job) => job.copyWith(
        state: SyncJobState.synced.wireName,
        availableAtUtc: syncedAtUtc,
        lastError: null,
      ),
    );
  }

  @override
  Future<void> resetInProgressJobs() async {
    for (var i = 0; i < jobs.length; i++) {
      if (jobs[i].parsedState == SyncJobState.inProgress) {
        jobs[i] = jobs[i].copyWith(state: SyncJobState.pending.wireName);
      }
    }
  }

  void _replace(String jobId, SyncJobEntity Function(SyncJobEntity job) map) {
    final index = jobs.indexWhere((SyncJobEntity job) => job.id == jobId);
    if (index == -1) {
      throw StateError('Missing sync job $jobId');
    }
    jobs[index] = map(jobs[index]);
  }
}

class _FakeSyncTaskExecutor implements SyncTaskExecutor {
  _FakeSyncTaskExecutor({required List<SyncTaskResult> results})
    : _results = Queue<SyncTaskResult>.from(results);

  final Queue<SyncTaskResult> _results;

  @override
  Future<SyncTaskResult> execute(SyncJobEntity job) async {
    if (_results.isEmpty) {
      throw const SocketException('No fake sync result configured.');
    }
    return _results.removeFirst();
  }
}

class _FixedSyncClock extends SyncClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 4, 29, 12, 0, 0);
}
