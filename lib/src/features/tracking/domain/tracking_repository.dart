import 'derived_metric_entity.dart';
import 'imu_chunk_entity.dart';
import 'tracking_point_entity.dart';
import 'tracking_session_entity.dart';

abstract class TrackingRepository {
  Future<TrackingSessionEntity> createSession({
    required int raceId,
    required String role,
    required int intervalSeconds,
    String? sensorHealthSnapshot,
  });

  Future<void> transitionSessionState({
    required int sessionId,
    required TrackingSessionState state,
    DateTime? endedAtUtc,
    String? failureReason,
    DateTime? lastSyncAtUtc,
    String? sensorHealthSnapshot,
  });

  Future<void> saveGpsPoint({required TrackingPointEntity point});

  Future<void> saveImuChunk({required ImuChunkEntity chunk});

  Future<bool> hasImuChunk({
    required int sessionId,
    required DateTime capturedAtUtc,
  });

  Future<void> saveDerivedMetrics(List<DerivedMetricEntity> metrics);

  Future<TrackingSessionEntity?> loadLatestUnfinishedSession();

  Future<TrackingSessionEntity?> loadSessionById(int sessionId);

  Future<List<TrackingPointEntity>> loadGpsPointsForSession(int sessionId);

  Future<List<TrackingPointEntity>> loadRecentGpsPointsForSession(
    int sessionId, {
    int limit = 2,
  });

  Future<TrackingPointEntity?> loadLatestGpsPointForSession(int sessionId);

  Future<List<DerivedMetricEntity>> loadDerivedMetricsForSession(
    int sessionId, {
    int? limit,
  });
}
