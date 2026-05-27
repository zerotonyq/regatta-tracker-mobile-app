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
      final response = await _receiverRemoteDataSource.uploadBatch(
        requestId: 'sync-${job.id}',
        raceId: payload.raceId,
        points: <UploadBatchPointDto>[_pointFromPayload(payload)],
      );
      return _resultFromResponse(response, payload.clientTaskId);
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

    final results = <String, SyncTaskResult>{...terminalResults};
    final entriesByRaceId =
        <
          int?,
          List<
            MapEntry<String, ({SyncJobEntity job, SyncUploadPayload payload})>
          >
        >{};
    for (final entry in payloadsByJobId.entries) {
      entriesByRaceId
          .putIfAbsent(entry.value.payload.raceId, () => [])
          .add(entry);
    }

    for (final raceGroup in entriesByRaceId.entries) {
      final raceId = raceGroup.key;
      final groupEntries = raceGroup.value;
      final requestId =
          'sync-batch-${raceId ?? 'none'}-${groupEntries.map((e) => e.key).join('-').hashCode.abs()}';

      final pointsByTimestamp = <String, UploadBatchPointDto>{};
      final duplicateJobIds = <String>{};
      for (final entry in groupEntries) {
        final point = _pointFromPayload(entry.value.payload);
        if (pointsByTimestamp.containsKey(point.timestampUtc)) {
          duplicateJobIds.add(entry.key);
          continue;
        }
        pointsByTimestamp[point.timestampUtc] = point;
      }

      late final UploadBatchResponseDto response;
      try {
        response = await _receiverRemoteDataSource.uploadBatch(
          requestId: requestId,
          raceId: raceId,
          points: pointsByTimestamp.values.toList(growable: false),
        );
      } catch (error) {
        final result = _mapError(error);
        for (final entry in groupEntries) {
          results[entry.key] = result;
        }
        continue;
      }

      final jobIdByClientTaskId = <String, String>{
        for (final entry in groupEntries)
          entry.value.payload.clientTaskId: entry.key,
      };
      for (final item in response.items) {
        final jobId = jobIdByClientTaskId[item.clientTaskId];
        if (jobId == null) {
          continue;
        }
        results[jobId] = _resultFromItem(item);
      }

      for (final entry in groupEntries) {
        results.putIfAbsent(entry.key, () => const SyncTaskResult.synced());
      }
      for (final duplicateJobId in duplicateJobIds) {
        results[duplicateJobId] = const SyncTaskResult.synced();
      }
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

  Future<SyncTaskResult> _handleApiCall(
    Future<SyncTaskResult> Function() call,
  ) async {
    try {
      return await call();
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

  SyncTaskResult _resultFromResponse(
    UploadBatchResponseDto response,
    String clientTaskId,
  ) {
    for (final item in response.items) {
      if (item.clientTaskId == clientTaskId) {
        return _resultFromItem(item);
      }
    }
    return response.skippedCount == 0
        ? const SyncTaskResult.synced()
        : const SyncTaskResult.retryableFailure(
            'Receiver did not return an item result for the upload.',
          );
  }

  SyncTaskResult _resultFromItem(UploadBatchItemResultDto item) {
    if (item.status == 'saved') {
      return const SyncTaskResult.synced();
    }
    if (item.status == 'skipped') {
      final message = item.message;
      if (message.contains("didn't start or ended")) {
        return SyncTaskResult.retryableFailure(message);
      }
      return SyncTaskResult.terminalFailure(message);
    }
    return SyncTaskResult.retryableFailure(item.message);
  }
}
