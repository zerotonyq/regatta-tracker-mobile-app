import '../../sync/application/queue_sync_upload_use_case.dart';
import '../../sync/domain/sync_job_entity.dart';
import '../../sync/domain/sync_job_state.dart';
import '../../sync/domain/sync_upload_payload.dart';
import '../domain/tracking_point_entity.dart';
import '../domain/tracking_repository.dart';

class UploadTrackingPointUseCase {
  const UploadTrackingPointUseCase(
    this._trackingRepository,
    this._queueSyncUploadUseCase,
  );

  final TrackingRepository _trackingRepository;
  final QueueSyncUploadUseCase _queueSyncUploadUseCase;

  Future<String> execute({required TrackingPointEntity point}) async {
    await _trackingRepository.saveGpsPoint(point: point);
    await _queueSyncUploadUseCase.execute(
      SyncJobEntity(
        id: 'gps-${point.sessionId}-${point.timestampUtc.microsecondsSinceEpoch}',
        type: 'gps_point_upload',
        state: SyncJobState.pending.wireName,
        createdAtUtc: DateTime.now().toUtc(),
        availableAtUtc: DateTime.now().toUtc(),
        sessionId: point.sessionId,
        payloadJson: SyncUploadPayload.fromTrackingPoint(
          point: point,
          clientTaskId:
              'gps-${point.sessionId}-${point.timestampUtc.microsecondsSinceEpoch}',
        ).toJson(),
        priority: 50,
      ),
    );
    return 'Point stored locally and queued for sync';
  }
}
