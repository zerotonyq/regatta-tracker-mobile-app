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

  test('passes race_id from payload to uploadBatch', () async {
    final fakeRemote = _FakeReceiverRemoteDataSource(
      response: _response(status: 'saved', message: 'OK'),
    );
    final executor = ReceiverSyncTaskExecutor(fakeRemote);

    final result = await executor.execute(_job(raceId: 555));

    expect(result.type, SyncTaskResultType.synced);
    expect(fakeRemote.uploadRaceIds, <int?>[555]);
  });

  test('splits batch uploads by race_id', () async {
    final fakeRemote = _FakeReceiverRemoteDataSource(
      response: _response(status: 'saved', message: 'OK'),
    );
    final executor = ReceiverSyncTaskExecutor(fakeRemote);

    final now = DateTime.utc(2026, 5, 26, 12);
    final results = await executor.executeBatch(<SyncJobEntity>[
      _job(id: 'job-1', clientTaskId: 'task-1', timestampUtc: now, raceId: 100),
      _job(
        id: 'job-2',
        clientTaskId: 'task-2',
        timestampUtc: now.add(const Duration(seconds: 1)),
        raceId: 200,
      ),
    ]);

    expect(results['job-1']?.type, SyncTaskResultType.synced);
    expect(results['job-2']?.type, SyncTaskResultType.synced);
    expect(fakeRemote.uploadRaceIds, <int?>[100, 200]);
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

SyncJobEntity _job({
  String id = '1',
  String clientTaskId = 'task-1',
  DateTime? timestampUtc,
  int? raceId,
}) {
  final now = DateTime.utc(2026, 5, 26, 12);
  final pointTime = timestampUtc ?? now;
  return SyncJobEntity(
    id: id,
    type: 'gps_point_upload',
    state: SyncJobState.pending.wireName,
    createdAtUtc: now,
    availableAtUtc: now,
    sessionId: 1,
    payloadJson: SyncUploadPayload(
      clientTaskId: clientTaskId,
      sessionId: 1,
      raceId: raceId,
      timestampUtc: pointTime,
      longitude: 30,
      latitude: 60,
    ).toJson(),
  );
}

class _FakeReceiverRemoteDataSource extends ReceiverRemoteDataSource {
  _FakeReceiverRemoteDataSource({required this.response})
    : super(receiverApi: null);

  final UploadBatchResponseDto response;
  final List<int?> uploadRaceIds = <int?>[];

  @override
  Future<UploadBatchResponseDto> uploadBatch({
    required String requestId,
    int? raceId,
    required List<UploadBatchPointDto> points,
  }) async {
    if (points.isEmpty) {
      throw ApiException(statusCode: 400, message: 'points required');
    }
    uploadRaceIds.add(raceId);
    return response;
  }
}
