import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

import '../../sensor_bridge/domain/sensor_bridge_repository.dart';
import '../domain/tracking_health.dart';
import '../domain/tracking_session_entity.dart';
import '../domain/tracking_session_failure.dart';
import '../domain/tracking_session_repository.dart';
import 'tracking_sample_ingestion_service.dart';

class TrackingSessionService {
  static const int defaultUploadIntervalSeconds = 5;

  TrackingSessionService({
    required TrackingSessionRepository trackingSessionRepository,
    required SensorBridgeRepository sensorBridgeRepository,
    TrackingSampleIngestionService? trackingSampleIngestionService,
  }) : _trackingSessionRepository = trackingSessionRepository,
       _sensorBridgeRepository = sensorBridgeRepository,
       _trackingSampleIngestionService = trackingSampleIngestionService;

  final TrackingSessionRepository _trackingSessionRepository;
  final SensorBridgeRepository _sensorBridgeRepository;
  final TrackingSampleIngestionService? _trackingSampleIngestionService;

  Future<TrackingSessionSnapshot> start({
    required int raceId,
    required String role,
  }) async {
    final health = await refreshHealth();
    _ensureCanTrack(health);

    final session = await _trackingSessionRepository.createSession(
      raceId: raceId,
      role: role,
      intervalSeconds: defaultUploadIntervalSeconds,
      state: TrackingSessionState.preparing,
      sensorHealthSnapshot: _serializeHealth(health),
    );

    try {
      final status = await _sensorBridgeRepository.startTrackingSession(
        config: _buildSessionConfig(
          sessionId: session.id.toString(),
          raceId: raceId,
          role: role,
          intervalSeconds: defaultUploadIntervalSeconds,
        ),
      );
      final activeSession = await _trackingSessionRepository
          .transitionSessionState(
            sessionId: session.id,
            state: _mapState(status.state),
            sensorHealthSnapshot: _serializeHealth(health),
          );
      await _trackingSampleIngestionService?.bind(activeSession);
      return TrackingSessionSnapshot(
        session: activeSession,
        health: await refreshHealth(sessionId: session.id),
      );
    } catch (error) {
      final message = _failureMessage(error);
      final failedSession = await _trackingSessionRepository
          .transitionSessionState(
            sessionId: session.id,
            state: TrackingSessionState.failed,
            failureReason: message,
            sensorHealthSnapshot: _serializeHealth(health),
          );
      throw TrackingSessionServiceException(
        session: failedSession,
        health: health,
        message: message,
      );
    }
  }

  Future<TrackingSessionSnapshot> pause(TrackingSessionEntity session) async {
    await _trackingSampleIngestionService?.unbind();
    final status = await _sensorBridgeRepository.pauseTrackingSession(
      sessionId: session.id.toString(),
    );
    final updated = await _trackingSessionRepository.transitionSessionState(
      sessionId: session.id,
      state: _mapState(status.state),
      sensorHealthSnapshot: session.sensorHealthSnapshot,
    );
    return TrackingSessionSnapshot(
      session: updated,
      health: await refreshHealth(sessionId: session.id),
    );
  }

  Future<TrackingSessionSnapshot> resume(TrackingSessionEntity session) async {
    final health = await refreshHealth(sessionId: session.id);
    _ensureCanTrack(health);
    final status = await _sensorBridgeRepository.resumeTrackingSession(
      sessionId: session.id.toString(),
    );

    final updated = await _trackingSessionRepository.transitionSessionState(
      sessionId: session.id,
      state: _mapState(status.state),
      sensorHealthSnapshot: _serializeHealth(health),
    );
    await _trackingSampleIngestionService?.bind(updated);
    return TrackingSessionSnapshot(session: updated, health: health);
  }

  Future<TrackingSessionSnapshot> stop(TrackingSessionEntity session) async {
    await _trackingSampleIngestionService?.unbind();
    final health = await refreshHealth(sessionId: session.id);
    final status = await _sensorBridgeRepository.stopTrackingSession(
      sessionId: session.id.toString(),
    );
    final updated = await _trackingSessionRepository.transitionSessionState(
      sessionId: session.id,
      state: _mapState(status.state),
      endedAtUtc: DateTime.now().toUtc(),
      lastSyncAtUtc: DateTime.now().toUtc(),
      sensorHealthSnapshot: _serializeHealth(health),
    );
    return TrackingSessionSnapshot(session: updated, health: health);
  }

  Future<TrackingSessionSnapshot?> restore() async {
    final session = await _trackingSessionRepository.restoreSession();
    if (session == null) {
      return null;
    }

    final nativeStatus = await _sensorBridgeRepository.getSessionStatus(
      sessionId: session.id.toString(),
    );
    final restoredSession = nativeStatus == null
        ? session
        : await _trackingSessionRepository.transitionSessionState(
            sessionId: session.id,
            state: _mapState(nativeStatus.state),
            sensorHealthSnapshot: session.sensorHealthSnapshot,
          );
    if (restoredSession.state == TrackingSessionState.tracking ||
        restoredSession.state == TrackingSessionState.preparing ||
        restoredSession.state == TrackingSessionState.syncing) {
      await _trackingSampleIngestionService?.bind(restoredSession);
    }

    return TrackingSessionSnapshot(
      session: restoredSession,
      health: await refreshHealth(sessionId: session.id),
    );
  }

  Future<TrackingHealth> refreshHealth({int? sessionId}) async {
    final baseHealth = await _sensorBridgeRepository.readTrackingHealth(
      sessionId: sessionId?.toString(),
    );
    final pendingSyncCount = await _trackingSessionRepository
        .getPendingSyncCount(sessionId: sessionId);
    final latestPoint = sessionId == null
        ? null
        : await _trackingSessionRepository.loadLatestGpsPoint(sessionId);

    final lastGpsSampleAgeMs = latestPoint == null
        ? baseHealth.lastGpsSampleAgeMs
        : DateTime.now()
              .toUtc()
              .difference(latestPoint.timestampUtc.toUtc())
              .inMilliseconds;

    return baseHealth.copyWith(
      pendingSyncCount: pendingSyncCount,
      gpsAccuracyMeters:
          latestPoint?.accuracyMeters ?? baseHealth.gpsAccuracyMeters,
      lastGpsSampleAgeMs: lastGpsSampleAgeMs,
    );
  }

  Future<TrackingHealth> requestRequiredPermissions() {
    return _sensorBridgeRepository.requestRequiredPermissions();
  }

  Stream<TrackingHealth> watchHealth({int? sessionId}) {
    return _sensorBridgeRepository.watchTrackingHealth(
      sessionId: sessionId?.toString(),
    );
  }

  Future<void> setTrackingProfile({
    required TrackingSessionEntity session,
    required TrackingProfile profile,
  }) {
    return _sensorBridgeRepository.setTrackingProfile(
      sessionId: session.id.toString(),
      profile: profile,
    );
  }

  Future<void> dispose() async {
    await _trackingSampleIngestionService?.dispose();
  }

  void _ensureCanTrack(TrackingHealth health) {
    if (!health.gpsEnabled) {
      throw TrackingSessionFailure('Геолокация на устройстве отключена.');
    }

    if (health.locationPermission != TrackingPermissionState.granted) {
      throw TrackingSessionFailure('Нет доступа к геолокации.');
    }
  }

  String _failureMessage(Object error) {
    if (error is TrackingSessionFailure) {
      return error.message;
    }
    return error.toString();
  }

  String _serializeHealth(TrackingHealth health) {
    return 'gpsEnabled=${health.gpsEnabled};'
        'imuEnabled=${health.imuEnabled};'
        'pendingSync=${health.pendingSyncCount};'
        'dropped=${health.droppedSampleCount};'
        'gpsAccuracy=${health.gpsAccuracyMeters?.toStringAsFixed(2) ?? 'n/a'}';
  }

  SessionConfig _buildSessionConfig({
    required String sessionId,
    required int raceId,
    required String role,
    required int intervalSeconds,
  }) {
    return SessionConfig(
      sessionId: sessionId,
      raceId: raceId,
      role: role,
      gpsHz: 1.0,
      imuHz: 50,
      desiredAccuracy: DesiredAccuracy.high,
      backgroundMode: BackgroundMode.foregroundService,
      bufferingPolicy: BufferingPolicy.persistNativeBuffer,
      initialTrackingProfile: TrackingProfile.prestartPrecision,
    );
  }

  TrackingSessionState _mapState(SessionLifecycleState state) {
    return switch (state) {
      SessionLifecycleState.idle => TrackingSessionState.idle,
      SessionLifecycleState.preparing => TrackingSessionState.preparing,
      SessionLifecycleState.tracking => TrackingSessionState.tracking,
      SessionLifecycleState.paused => TrackingSessionState.paused,
      SessionLifecycleState.syncing => TrackingSessionState.syncing,
      SessionLifecycleState.stopped => TrackingSessionState.completed,
      SessionLifecycleState.failed => TrackingSessionState.failed,
    };
  }
}

class TrackingSessionSnapshot {
  const TrackingSessionSnapshot({required this.session, required this.health});

  final TrackingSessionEntity session;
  final TrackingHealth health;
}

class TrackingSessionServiceException implements Exception {
  TrackingSessionServiceException({
    required this.session,
    required this.health,
    required this.message,
  });

  final TrackingSessionEntity session;
  final TrackingHealth health;
  final String message;
}
