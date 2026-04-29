import '../../sync/domain/sync_job_entity.dart';
import 'tracking_point_entity.dart';
import 'tracking_session_entity.dart';

abstract class TrackingSessionRepository {
  Future<TrackingSessionEntity> createSession({
    required int raceId,
    required String role,
    required int intervalSeconds,
    required TrackingSessionState state,
    String? sensorHealthSnapshot,
  });

  Future<TrackingSessionEntity?> restoreSession();

  Future<TrackingSessionEntity> transitionSessionState({
    required int sessionId,
    required TrackingSessionState state,
    DateTime? endedAtUtc,
    String? failureReason,
    DateTime? lastSyncAtUtc,
    String? sensorHealthSnapshot,
  });

  Future<void> saveGpsPoint(TrackingPointEntity point);

  Future<void> queueGpsPointForSync(TrackingPointEntity point);

  Future<TrackingPointEntity?> loadLatestGpsPoint(int sessionId);

  Future<int> getPendingSyncCount({int? sessionId});

  Future<List<SyncJobEntity>> loadPendingSyncJobs();
}
