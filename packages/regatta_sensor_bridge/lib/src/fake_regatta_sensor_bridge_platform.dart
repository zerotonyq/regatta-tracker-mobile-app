import 'dart:async';

import 'regatta_sensor_bridge_api.dart';
import 'regatta_sensor_bridge_platform_interface.dart';

class FakeRegattaSensorBridgePlatform extends RegattaSensorBridgePlatform {
  FakeRegattaSensorBridgePlatform({
    HealthEvent? initialHealth,
    Map<String, SessionStatus>? seededSessions,
  }) : _currentHealth = initialHealth ?? _defaultHealth() {
    if (seededSessions != null) {
      _sessions.addAll(seededSessions);
    }
  }

  final Map<String, SessionStatus> _sessions = <String, SessionStatus>{};
  final StreamController<SampleBatch> _sampleController =
      StreamController<SampleBatch>.broadcast();
  final StreamController<HealthEvent> _healthController =
      StreamController<HealthEvent>.broadcast();

  HealthEvent _currentHealth;

  @override
  Future<SessionStatus?> getSessionStatus(String sessionId) async {
    return _sessions[sessionId];
  }

  @override
  Future<HealthEvent> requestRequiredPermissions() async {
    final updated = _currentHealth.copyWith(
      locationPermission: PermissionStatus.granted,
      motionPermission: PermissionStatus.granted,
    );
    _emitHealth(updated);
    return updated;
  }

  @override
  Future<HealthEvent> getTrackingHealth({String? sessionId}) async {
    return _currentHealth.copyWith(sessionId: sessionId);
  }

  @override
  Future<SessionStatus> pauseTrackingSession(String sessionId) async {
    final current = _requireSession(sessionId);
    final updated = current.copyWith(
      state: SessionLifecycleState.paused,
      pausedAt: DateTime.now().toUtc(),
      activeProfile: TrackingProfile.paused,
    );
    _sessions[sessionId] = updated;
    _emitHealth(
      _currentHealth.copyWith(
        sessionId: sessionId,
        backgroundServiceRunning: false,
      ),
    );
    return updated;
  }

  @override
  Future<SessionStatus> resumeTrackingSession(String sessionId) async {
    final current = _requireSession(sessionId);
    final updated = current.copyWith(
      state: SessionLifecycleState.tracking,
      pausedAt: null,
      activeProfile: TrackingProfile.raceCruise,
    );
    _sessions[sessionId] = updated;
    _emitHealth(
      _currentHealth.copyWith(
        sessionId: sessionId,
        backgroundServiceRunning: true,
      ),
    );
    return updated;
  }

  @override
  Future<void> setTrackingProfile(
    String sessionId,
    TrackingProfile profile,
  ) async {
    final current = _requireSession(sessionId);
    _sessions[sessionId] = current.copyWith(activeProfile: profile);
  }

  @override
  Future<SessionStatus> startTrackingSession(SessionConfig config) async {
    final now = DateTime.now().toUtc();
    final status = SessionStatus(
      state: SessionLifecycleState.tracking,
      sessionId: config.sessionId,
      startedAt: now,
      lastSampleAt: now,
      activeProfile: config.initialTrackingProfile,
    );
    _sessions[config.sessionId] = status;
    _emitHealth(
      _currentHealth.copyWith(
        sessionId: config.sessionId,
        backgroundServiceRunning: true,
        targetGpsHz: config.gpsHz,
        targetImuHz: config.imuHz,
      ),
    );
    return status;
  }

  @override
  Future<SessionStatus> stopTrackingSession(String sessionId) async {
    final current = _requireSession(sessionId);
    final updated = current.copyWith(
      state: SessionLifecycleState.stopped,
      activeProfile: TrackingProfile.paused,
    );
    _sessions[sessionId] = updated;
    _emitHealth(
      _currentHealth.copyWith(
        sessionId: sessionId,
        backgroundServiceRunning: false,
      ),
    );
    return updated;
  }

  @override
  Stream<HealthEvent> streamHealth({String? sessionId}) async* {
    yield _currentHealth.copyWith(sessionId: sessionId);
    yield* _healthController.stream.where(
      (HealthEvent event) => sessionId == null || event.sessionId == sessionId,
    );
  }

  @override
  Stream<SampleBatch> streamSamples({String? sessionId}) {
    return _sampleController.stream.where(
      (SampleBatch event) => sessionId == null || event.sessionId == sessionId,
    );
  }

  void emitSampleBatch(SampleBatch batch) {
    final session = _sessions[batch.sessionId];
    if (session != null) {
      _sessions[batch.sessionId] = session.copyWith(
        lastSampleAt: batch.recordedAt,
      );
    }
    _sampleController.add(batch);
  }

  void emitHealthEvent(HealthEvent event) {
    _emitHealth(event);
  }

  void _emitHealth(HealthEvent event) {
    _currentHealth = event;
    _healthController.add(event);
  }

  SessionStatus _requireSession(String sessionId) {
    final status = _sessions[sessionId];
    if (status != null) {
      return status;
    }

    throw const SensorBridgeException(
      NativeError(
        code: 'missing_session',
        message: 'Tracking session is not registered in fake bridge.',
        isRecoverable: false,
      ),
    );
  }

  static HealthEvent _defaultHealth() {
    return HealthEvent(
      sessionId: null,
      recordedAt: DateTime.now().toUtc(),
      locationPermission: PermissionStatus.granted,
      motionPermission: PermissionStatus.unknown,
      gpsAvailable: true,
      imuAvailable: false,
      backgroundServiceRunning: false,
      droppedSamples: 0,
      queueDepth: 0,
      serviceRestarts: 0,
    );
  }
}

extension on HealthEvent {
  HealthEvent copyWith({
    String? sessionId,
    DateTime? recordedAt,
    PermissionStatus? locationPermission,
    PermissionStatus? motionPermission,
    bool? gpsAvailable,
    bool? imuAvailable,
    bool? backgroundServiceRunning,
    int? droppedSamples,
    int? queueDepth,
    double? batteryPercent,
    int? lastGpsSampleAgeMs,
    int? lastImuSampleAgeMs,
    double? gpsAccuracyMeters,
    double? targetGpsHz,
    double? targetImuHz,
    NativeError? error,
  }) {
    return HealthEvent(
      sessionId: sessionId ?? this.sessionId,
      recordedAt: recordedAt ?? DateTime.now().toUtc(),
      locationPermission: locationPermission ?? this.locationPermission,
      motionPermission: motionPermission ?? this.motionPermission,
      gpsAvailable: gpsAvailable ?? this.gpsAvailable,
      imuAvailable: imuAvailable ?? this.imuAvailable,
      backgroundServiceRunning:
          backgroundServiceRunning ?? this.backgroundServiceRunning,
      droppedSamples: droppedSamples ?? this.droppedSamples,
      queueDepth: queueDepth ?? this.queueDepth,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      lastGpsSampleAgeMs: lastGpsSampleAgeMs ?? this.lastGpsSampleAgeMs,
      lastImuSampleAgeMs: lastImuSampleAgeMs ?? this.lastImuSampleAgeMs,
      gpsAccuracyMeters: gpsAccuracyMeters ?? this.gpsAccuracyMeters,
      receivedGpsSamples: receivedGpsSamples,
      receivedImuSamples: receivedImuSamples,
      targetGpsHz: targetGpsHz ?? this.targetGpsHz,
      targetImuHz: targetImuHz ?? this.targetImuHz,
      averageGpsRateHz: averageGpsRateHz,
      averageImuRateHz: averageImuRateHz,
      lastGpsSensorTimestamp: lastGpsSensorTimestamp,
      lastImuSensorTimestamp: lastImuSensorTimestamp,
      serviceRestarts: serviceRestarts,
      activeTrackingProfile: activeTrackingProfile,
      statusMessage: statusMessage,
      storagePath: storagePath,
      error: error ?? this.error,
    );
  }
}
