import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_failure.dart';
import '../../../core/network/network_failure.dart';
import '../../receiver/data/receiver_remote_data_source.dart';
import '../../api/models/api_models.dart';
import '../domain/sync_batch_task_executor.dart';
import '../domain/sync_job_entity.dart';
import '../domain/sync_task_executor.dart';
import '../domain/sync_task_result.dart';
import '../domain/sync_upload_payload.dart';

class ReceiverSyncTaskExecutor
    implements SyncTaskExecutor, SyncBatchTaskExecutor {
  const ReceiverSyncTaskExecutor(this._receiverRemoteDataSource);

  final ReceiverRemoteDataSource _receiverRemoteDataSource;

  @override
  Future<SyncTaskResult> execute(SyncJobEntity job) async {
    if (job.type != 'gps_point_upload') {
      return SyncTaskResult.terminalFailure(
        'Unsupported sync job type: ${job.type}',
      );
    }

    final payload = job.uploadPayload;
    if (payload == null) {
      return const SyncTaskResult.terminalFailure(
        'Sync payload is missing or malformed.',
      );
    }

    return _handleApiCall(() async {
      await _receiverRemoteDataSource.uploadBatch(
        requestId: 'sync-${job.id}',
        points: <UploadBatchPointDto>[_pointFromPayload(payload)],
      );
    });
  }

  @override
  Future<Map<String, SyncTaskResult>> executeBatch(
    List<SyncJobEntity> jobs,
  ) async {
    final payloadsByJobId =
        <String, ({SyncJobEntity job, SyncUploadPayload payload})>{};
    final terminalResults = <String, SyncTaskResult>{};

    for (final job in jobs) {
      if (job.type != 'gps_point_upload') {
        terminalResults[job.id] = SyncTaskResult.terminalFailure(
          'Unsupported sync job type: ${job.type}',
        );
        continue;
      }

      final payload = job.uploadPayload;
      if (payload == null) {
        terminalResults[job.id] = const SyncTaskResult.terminalFailure(
          'Sync payload is missing or malformed.',
        );
        continue;
      }
      payloadsByJobId[job.id] = (job: job, payload: payload);
    }

    if (payloadsByJobId.isEmpty) {
      return terminalResults;
    }

    final requestId =
        'sync-batch-${payloadsByJobId.keys.join('-').hashCode.abs()}';
    late final UploadBatchResponseDto response;
    try {
      response = await _receiverRemoteDataSource.uploadBatch(
        requestId: requestId,
        points: payloadsByJobId.values
            .map((entry) => _pointFromPayload(entry.payload))
            .toList(growable: false),
      );
    } catch (error) {
      final result = _mapError(error);
      return <String, SyncTaskResult>{
        for (final id in payloadsByJobId.keys) id: result,
        ...terminalResults,
      };
    }

    final results = <String, SyncTaskResult>{...terminalResults};
    final jobIdByClientTaskId = <String, String>{
      for (final entry in payloadsByJobId.entries)
        entry.value.payload.clientTaskId: entry.key,
    };
    for (final item in response.items) {
      final jobId = jobIdByClientTaskId[item.clientTaskId];
      if (jobId == null) {
        continue;
      }
      results[jobId] = item.status == 'saved' || item.status == 'skipped'
          ? const SyncTaskResult.synced()
          : SyncTaskResult.retryableFailure(item.message);
    }
    for (final jobId in payloadsByJobId.keys) {
      results.putIfAbsent(jobId, () => const SyncTaskResult.synced());
    }
    return results;
  }

  UploadBatchPointDto _pointFromPayload(SyncUploadPayload payload) {
    return UploadBatchPointDto(
      clientTaskId: payload.clientTaskId,
      sessionId: payload.sessionId,
      timestampUtc: payload.timestampUtc.toUtc().toIso8601String(),
      longitude: payload.longitude,
      latitude: payload.latitude,
      accuracyMeters: payload.accuracyMeters,
      speedMetersPerSecond: payload.speedMetersPerSecond,
    );
  }

  Future<SyncTaskResult> _handleApiCall(Future<void> Function() call) async {
    try {
      await call();
      return const SyncTaskResult.synced();
    } catch (error) {
      return _mapError(error);
    }
  }

  SyncTaskResult _mapError(Object error) {
    if (error is NetworkFailure) {
      if (error.isRetryable || error.type == NetworkFailureType.server) {
        return SyncTaskResult.retryableFailure(error.message);
      }
      return SyncTaskResult.terminalFailure(error.message);
    }
    if (error is AuthFailure) {
      return SyncTaskResult.terminalFailure(error.message);
    }
    if (error is ApiException) {
      final statusCode = error.statusCode;
      if (statusCode == 401 || statusCode == 403 || statusCode == 400) {
        return SyncTaskResult.terminalFailure(error.message);
      }
      if (statusCode != null && statusCode >= 500) {
        return SyncTaskResult.retryableFailure(error.message);
      }
      return SyncTaskResult.terminalFailure(error.message);
    }
    return SyncTaskResult.retryableFailure(error.toString());
  }
}
