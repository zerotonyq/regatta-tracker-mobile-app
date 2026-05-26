import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/core/network/api_exception.dart';
import 'package:vkr_regatta/src/features/api/models/api_models.dart';
import 'package:vkr_regatta/src/features/receiver/data/receiver_remote_data_source.dart';
import 'package:vkr_regatta/src/features/sync/data/receiver_sync_task_executor.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_job_entity.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_job_state.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_task_result.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_upload_payload.dart';

void main() {
  test(
    'retries receiver skipped points when race window is not accepting data',
    () async {
      final executor = ReceiverSyncTaskExecutor(
        _FakeReceiverRemoteDataSource(
          response: _response(
            status: 'skipped',
            message:
                "The race either didn't start or ended. The received coordinates were not saved",
          ),
        ),
      );

      final result = await executor.execute(_job());

      expect(result.type, SyncTaskResultType.retryableFailure);
    },
  );

  test('marks invalid skipped points as terminal failures', () async {
    final executor = ReceiverSyncTaskExecutor(
      _FakeReceiverRemoteDataSource(
        response: _response(
          status: 'skipped',
          message: 'Longitude can take a value from -180 to 180',
        ),
      ),
    );

    final result = await executor.execute(_job());

    expect(result.type, SyncTaskResultType.terminalFailure);
  });
}

UploadBatchResponseDto _response({
  required String status,
  required String message,
}) {
  return UploadBatchResponseDto(
    requestId: 'sync-1',
    savedCount: status == 'saved' ? 1 : 0,
    skippedCount: status == 'skipped' ? 1 : 0,
    items: <UploadBatchItemResultDto>[
      UploadBatchItemResultDto(
        clientTaskId: 'task-1',
        sessionId: 1,
        status: status,
        message: message,
      ),
    ],
  );
}

SyncJobEntity _job() {
  final now = DateTime.utc(2026, 5, 26, 12);
  return SyncJobEntity(
    id: '1',
    type: 'gps_point_upload',
    state: SyncJobState.pending.wireName,
    createdAtUtc: now,
    availableAtUtc: now,
    sessionId: 1,
    payloadJson: SyncUploadPayload(
      clientTaskId: 'task-1',
      sessionId: 1,
      timestampUtc: DateTime.utc(2026, 5, 26, 12),
      longitude: 30,
      latitude: 60,
    ).toJson(),
  );
}

class _FakeReceiverRemoteDataSource extends ReceiverRemoteDataSource {
  _FakeReceiverRemoteDataSource({required this.response})
    : super(receiverApi: null);

  final UploadBatchResponseDto response;

  @override
  Future<UploadBatchResponseDto> uploadBatch({
    required String requestId,
    int? raceId,
    required List<UploadBatchPointDto> points,
  }) async {
    if (points.isEmpty) {
      throw ApiException(statusCode: 400, message: 'points required');
    }
    return response;
  }
}
