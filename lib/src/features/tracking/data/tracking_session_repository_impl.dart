import '../../sync/domain/sync_job_entity.dart';
import '../../sync/domain/sync_repository.dart';
import '../../sync/domain/sync_job_state.dart';
import '../../sync/domain/sync_upload_payload.dart';
import '../domain/tracking_point_entity.dart';
import '../domain/tracking_repository.dart';
import '../domain/tracking_session_entity.dart';
import '../domain/tracking_session_repository.dart';

class TrackingSessionRepositoryImpl implements TrackingSessionRepository {
  const TrackingSessionRepositoryImpl({
    required TrackingRepository trackingRepository,
    required SyncRepository syncRepository,
  }) : _trackingRepository = trackingRepository,
       _syncRepository = syncRepository;

  final TrackingRepository _trackingRepository;
  final SyncRepository _syncRepository;

  @override
  Future<TrackingSessionEntity> createSession({
    required int raceId,
    required String role,
    required int intervalSeconds,
    required TrackingSessionState state,
    String? sensorHealthSnapshot,
  }) async {
    final session = await _trackingRepository.createSession(
      raceId: raceId,
      role: role,
      intervalSeconds: intervalSeconds,
      sensorHealthSnapshot: sensorHealthSnapshot,
    );

    if (session.state == state) {
      return session;
    }

    return transitionSessionState(
      sessionId: session.id,
      state: state,
      sensorHealthSnapshot: sensorHealthSnapshot,
    );
  }

  @override
  Future<int> getPendingSyncCount({int? sessionId}) async {
    final jobs = await _syncRepository.getPendingJobs();
    if (sessionId == null) {
      return jobs.length;
    }

    return jobs.where((job) => job.sessionId == sessionId).length;
  }

  @override
  Future<TrackingPointEntity?> loadLatestGpsPoint(int sessionId) async {
    return _trackingRepository.loadLatestGpsPointForSession(sessionId);
  }

  @override
  Future<List<SyncJobEntity>> loadPendingSyncJobs() {
    return _syncRepository.getPendingJobs();
  }

  @override
  Future<TrackingSessionEntity?> restoreSession() {
    return _trackingRepository.loadLatestUnfinishedSession();
  }

  @override
  Future<void> saveGpsPoint(TrackingPointEntity point) async {
    await _trackingRepository.saveGpsPoint(point: point);
  }

  @override
  Future<void> queueGpsPointForSync(TrackingPointEntity point) async {
    final sessionId = point.sessionId;
    if (sessionId == null) {
      return;
    }
    final session = await _trackingRepository.loadSessionById(sessionId);

    final taskId =
        'gps-$sessionId-${point.timestampUtc.microsecondsSinceEpoch}';
    await _syncRepository.enqueue(
      SyncJobEntity(
        id: taskId,
        type: 'gps_point_upload',
        state: SyncJobState.pending.wireName,
        createdAtUtc: DateTime.now().toUtc(),
        availableAtUtc: DateTime.now().toUtc(),
        sessionId: sessionId,
        payloadJson: SyncUploadPayload.fromTrackingPoint(
          point: point,
          clientTaskId: taskId,
          raceId: session?.raceId,
        ).toJson(),
        priority: 50,
      ),
    );
  }

  @override
  Future<TrackingSessionEntity> transitionSessionState({
    required int sessionId,
    required TrackingSessionState state,
    DateTime? endedAtUtc,
    String? failureReason,
    DateTime? lastSyncAtUtc,
    String? sensorHealthSnapshot,
  }) async {
    await _trackingRepository.transitionSessionState(
      sessionId: sessionId,
      state: state,
      endedAtUtc: endedAtUtc,
      failureReason: failureReason,
      lastSyncAtUtc: lastSyncAtUtc,
      sensorHealthSnapshot: sensorHealthSnapshot,
    );

    final updatedSession = await _trackingRepository.loadSessionById(sessionId);
    if (updatedSession != null) {
      return updatedSession;
    }

    return TrackingSessionEntity(
      id: sessionId,
      raceId: 0,
      role: 'participant',
      state: state,
      intervalSeconds: 0,
      startedAtUtc: DateTime.now().toUtc(),
      endedAtUtc: endedAtUtc,
      failureReason: failureReason,
      lastSyncAtUtc: lastSyncAtUtc,
      sensorHealthSnapshot: sensorHealthSnapshot,
    );
  }
}
