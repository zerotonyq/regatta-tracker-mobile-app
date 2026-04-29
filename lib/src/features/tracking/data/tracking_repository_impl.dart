import '../../local_storage/database/app_database.dart';
import '../domain/derived_metric_entity.dart';
import '../domain/imu_chunk_entity.dart';
import '../domain/tracking_point_entity.dart';
import '../domain/tracking_repository.dart';
import '../domain/tracking_session_entity.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  const TrackingRepositoryImpl(this._appDatabase);

  final AppDatabase _appDatabase;

  @override
  Future<TrackingSessionEntity> createSession({
    required int raceId,
    required String role,
    required int intervalSeconds,
    String? sensorHealthSnapshot,
  }) {
    return _appDatabase.trackingSessionDao.createSession(
      raceId: raceId,
      role: role,
      intervalSeconds: intervalSeconds,
      state: TrackingSessionState.preparing,
      sensorHealthSnapshot: sensorHealthSnapshot,
    );
  }

  @override
  Future<List<TrackingPointEntity>> loadGpsPointsForSession(int sessionId) {
    return _appDatabase.trackingPointDao.loadPointsForSession(sessionId);
  }

  @override
  Future<List<DerivedMetricEntity>> loadDerivedMetricsForSession(
    int sessionId, {
    int? limit,
  }) {
    return _appDatabase.derivedMetricDao.loadMetricsForSession(
      sessionId,
      limit: limit,
    );
  }

  @override
  Future<TrackingPointEntity?> loadLatestGpsPointForSession(int sessionId) {
    return _appDatabase.trackingPointDao.loadLatestPointForSession(sessionId);
  }

  @override
  Future<List<TrackingPointEntity>> loadRecentGpsPointsForSession(
    int sessionId, {
    int limit = 2,
  }) {
    return _appDatabase.trackingPointDao.loadRecentPointsForSession(
      sessionId,
      limit: limit,
    );
  }

  @override
  Future<TrackingSessionEntity?> loadLatestUnfinishedSession() {
    return _appDatabase.trackingSessionDao.loadLatestUnfinishedSession();
  }

  @override
  Future<TrackingSessionEntity?> loadSessionById(int sessionId) {
    return _appDatabase.trackingSessionDao.loadSessionById(sessionId);
  }

  @override
  Future<void> saveGpsPoint({required TrackingPointEntity point}) {
    return _appDatabase.trackingPointDao.insertPoint(point);
  }

  @override
  Future<void> saveImuChunk({required ImuChunkEntity chunk}) {
    return _appDatabase.imuChunkDao.insertChunk(chunk);
  }

  @override
  Future<bool> hasImuChunk({
    required int sessionId,
    required DateTime capturedAtUtc,
  }) {
    return _appDatabase.imuChunkDao.existsChunkForSessionAt(
      sessionId: sessionId,
      capturedAtUtc: capturedAtUtc,
    );
  }

  @override
  Future<void> saveDerivedMetrics(List<DerivedMetricEntity> metrics) {
    return _appDatabase.derivedMetricDao.insertMetrics(metrics);
  }

  @override
  Future<void> transitionSessionState({
    required int sessionId,
    required TrackingSessionState state,
    DateTime? endedAtUtc,
    String? failureReason,
    DateTime? lastSyncAtUtc,
    String? sensorHealthSnapshot,
  }) {
    return _appDatabase.trackingSessionDao.transitionSessionState(
      sessionId: sessionId,
      state: state,
      endedAtUtc: endedAtUtc,
      failureReason: failureReason,
      lastSyncAtUtc: lastSyncAtUtc,
      sensorHealthSnapshot: sensorHealthSnapshot,
    );
  }
}
