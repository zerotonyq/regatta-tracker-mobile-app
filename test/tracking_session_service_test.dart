import 'package:flutter_test/flutter_test.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';
import 'package:vkr_regatta/src/features/sensor_bridge/domain/sensor_bridge_repository.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_job_entity.dart';
import 'package:vkr_regatta/src/features/tracking/application/tracking_session_service.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_health.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_point_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_session_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_session_repository.dart';
import 'package:vkr_regatta/src/features/tracking/presentation/tracking_session_controller.dart';

void main() {
  group('TrackingSessionService', () {
    test(
      'start registers native bridge session and transitions local session to tracking',
      () async {
        final repository = _FakeTrackingSessionRepository();
        final sensorBridge = _FakeSensorBridgeRepository(
          health: _healthyTrackingHealth(),
        );
        final service = TrackingSessionService(
          trackingSessionRepository: repository,
          sensorBridgeRepository: sensorBridge,
        );

        final snapshot = await service.start(raceId: 42, role: 'participant');

        expect(snapshot.session.state, TrackingSessionState.tracking);
        expect(repository.transitions, [TrackingSessionState.tracking]);
        expect(sensorBridge.startedConfigs, hasLength(1));
        expect(sensorBridge.startedConfigs.single.sessionId, '1');
        expect(sensorBridge.startedConfigs.single.gpsHz, 1.0);
        expect(sensorBridge.startedConfigs.single.imuHz, 50.0);
        expect(
          sensorBridge.startedConfigs.single.bufferingPolicy,
          BufferingPolicy.persistNativeBuffer,
        );
        expect(
          sensorBridge.startedConfigs.single.initialTrackingProfile,
          TrackingProfile.prestartPrecision,
        );
      },
    );

    test('start fails when bridge cannot start native tracking', () async {
      final repository = _FakeTrackingSessionRepository();
      final sensorBridge = _FakeSensorBridgeRepository(
        health: _healthyTrackingHealth(),
        startError: const SensorBridgeException(
          NativeError(
            code: 'permission_denied',
            message: 'Location permission is denied.',
            isRecoverable: true,
          ),
        ),
      );
      final service = TrackingSessionService(
        trackingSessionRepository: repository,
        sensorBridgeRepository: sensorBridge,
      );

      await expectLater(
        service.start(raceId: 7, role: 'participant'),
        throwsA(isA<TrackingSessionServiceException>()),
      );
      expect(repository.session?.state, TrackingSessionState.failed);
      expect(repository.transitions, [TrackingSessionState.failed]);
    });

    test(
      'restore returns unfinished session with persisted health context',
      () async {
        final repository = _FakeTrackingSessionRepository(
          initialSession: TrackingSessionEntity(
            id: 5,
            raceId: 77,
            role: 'participant',
            state: TrackingSessionState.paused,
            intervalSeconds: 3,
            startedAtUtc: DateTime.utc(2026, 4, 29, 9, 0, 0),
          ),
          initialPoints: [
            TrackingPointEntity(
              sessionId: 5,
              timestampUtc: DateTime.now().toUtc().subtract(
                const Duration(seconds: 3),
              ),
              longitude: 30.0,
              latitude: 60.0,
              accuracyMeters: 2.2,
            ),
          ],
          pendingJobs: [
            SyncJobEntity(
              id: 'job-1',
              type: 'gps_point_upload',
              state: 'pending',
              createdAtUtc: DateTime.utc(2026, 4, 29, 9, 0, 1),
              availableAtUtc: DateTime.utc(2026, 4, 29, 9, 0, 1),
              sessionId: 5,
            ),
          ],
        );
        final sensorBridge = _FakeSensorBridgeRepository(
          health: _healthyTrackingHealth(),
        );
        final service = TrackingSessionService(
          trackingSessionRepository: repository,
          sensorBridgeRepository: sensorBridge,
        );

        final snapshot = await service.restore();

        expect(snapshot, isNotNull);
        expect(snapshot!.session.id, 5);
        expect(snapshot.session.state, TrackingSessionState.paused);
        expect(snapshot.health.pendingSyncCount, 1);
        expect(snapshot.health.gpsAccuracyMeters, 2.2);
        expect(snapshot.health.lastGpsSampleAgeMs, greaterThanOrEqualTo(2500));
      },
    );
  });

  test(
    'TrackingSessionController restores paused session and resumes through service',
    () async {
      final repository = _FakeTrackingSessionRepository(
        initialSession: TrackingSessionEntity(
          id: 9,
          raceId: 101,
          role: 'participant',
          state: TrackingSessionState.paused,
          intervalSeconds: 4,
          startedAtUtc: DateTime.utc(2026, 4, 29, 11, 0, 0),
        ),
      );
      final sensorBridge = _FakeSensorBridgeRepository(
        health: _healthyTrackingHealth(),
      );
      final service = TrackingSessionService(
        trackingSessionRepository: repository,
        sensorBridgeRepository: sensorBridge,
      );
      final controller = TrackingSessionController(
        trackingSessionService: service,
      );

      await controller.restore();
      expect(controller.state, TrackingSessionState.paused);
      expect(controller.raceId, 101);

      await controller.resume();
      expect(controller.state, TrackingSessionState.tracking);
      expect(controller.error, isNull);
    },
  );

  test(
    'TrackingSessionController publishes recommended tracking profile',
    () async {
      final repository = _FakeTrackingSessionRepository(
        initialSession: TrackingSessionEntity(
          id: 9,
          raceId: 101,
          role: 'participant',
          state: TrackingSessionState.tracking,
          intervalSeconds: 4,
          startedAtUtc: DateTime.utc(2026, 4, 29, 11, 0, 0),
        ),
      );
      final sensorBridge = _FakeSensorBridgeRepository(
        health: _healthyTrackingHealth(),
      );
      final service = TrackingSessionService(
        trackingSessionRepository: repository,
        sensorBridgeRepository: sensorBridge,
      );
      final controller = TrackingSessionController(
        trackingSessionService: service,
      );

      await controller.restore();
      await controller.setTrackingProfile(
        TrackingProfile.markRoundingPrecision,
      );

      expect(sensorBridge.publishedProfiles, <TrackingProfile>[
        TrackingProfile.markRoundingPrecision,
      ]);
    },
  );
}

TrackingHealth _healthyTrackingHealth() {
  return const TrackingHealth(
    locationPermission: TrackingPermissionState.granted,
    motionPermission: TrackingPermissionState.unknown,
    gpsEnabled: true,
    imuEnabled: false,
    backgroundServiceRunning: false,
    pendingSyncCount: 0,
    droppedSampleCount: 0,
    activeTrackingProfile: TrackingProfile.raceCruise,
  );
}

class _FakeSensorBridgeRepository implements SensorBridgeRepository {
  _FakeSensorBridgeRepository({required this.health, this.startError});

  final TrackingHealth health;
  final Object? startError;
  final List<SessionConfig> startedConfigs = <SessionConfig>[];
  final List<TrackingProfile> publishedProfiles = <TrackingProfile>[];

  @override
  Future<TrackingHealth> requestRequiredPermissions() async => health;

  @override
  Future<SessionStatus?> getSessionStatus({required String sessionId}) async {
    return SessionStatus(
      state: SessionLifecycleState.paused,
      sessionId: sessionId,
      startedAt: DateTime.utc(2026, 4, 29, 11, 0, 0),
      activeProfile: TrackingProfile.paused,
    );
  }

  @override
  Future<SessionStatus> pauseTrackingSession({
    required String sessionId,
  }) async {
    return SessionStatus(
      state: SessionLifecycleState.paused,
      sessionId: sessionId,
      startedAt: DateTime.utc(2026, 4, 29, 11, 0, 0),
      pausedAt: DateTime.utc(2026, 4, 29, 11, 5, 0),
      activeProfile: TrackingProfile.paused,
    );
  }

  @override
  Future<TrackingHealth> readTrackingHealth({String? sessionId}) async =>
      health;

  @override
  Future<SessionStatus> resumeTrackingSession({
    required String sessionId,
  }) async {
    return SessionStatus(
      state: SessionLifecycleState.tracking,
      sessionId: sessionId,
      startedAt: DateTime.utc(2026, 4, 29, 11, 0, 0),
      activeProfile: TrackingProfile.raceCruise,
    );
  }

  @override
  Future<void> setTrackingProfile({
    required String sessionId,
    required TrackingProfile profile,
  }) async {
    publishedProfiles.add(profile);
  }

  @override
  Future<SessionStatus> startTrackingSession({
    required SessionConfig config,
  }) async {
    if (startError != null) {
      throw startError!;
    }

    startedConfigs.add(config);
    return SessionStatus(
      state: SessionLifecycleState.tracking,
      sessionId: config.sessionId,
      startedAt: DateTime.utc(2026, 4, 29, 10, 0, 0),
      lastSampleAt: DateTime.utc(2026, 4, 29, 10, 0, 1),
      activeProfile: config.initialTrackingProfile,
    );
  }

  @override
  Future<SessionStatus> stopTrackingSession({required String sessionId}) async {
    return SessionStatus(
      state: SessionLifecycleState.stopped,
      sessionId: sessionId,
      startedAt: DateTime.utc(2026, 4, 29, 11, 0, 0),
      activeProfile: TrackingProfile.paused,
    );
  }

  @override
  Stream<HealthEvent> streamHealth({String? sessionId}) {
    return Stream<HealthEvent>.value(
      HealthEvent(
        sessionId: sessionId,
        recordedAt: DateTime.utc(2026, 4, 29, 11, 0, 0),
        locationPermission: PermissionStatus.granted,
        motionPermission: PermissionStatus.unknown,
        gpsAvailable: health.gpsEnabled,
        imuAvailable: health.imuEnabled,
        backgroundServiceRunning: health.backgroundServiceRunning,
        droppedSamples: health.droppedSampleCount,
        queueDepth: health.pendingSyncCount,
        gpsAccuracyMeters: health.gpsAccuracyMeters,
        lastGpsSampleAgeMs: health.lastGpsSampleAgeMs,
        lastImuSampleAgeMs: health.lastImuSampleAgeMs,
      ),
    );
  }

  @override
  Stream<SampleBatch> streamSamples({String? sessionId}) {
    return const Stream<SampleBatch>.empty();
  }

  @override
  Stream<TrackingHealth> watchTrackingHealth({String? sessionId}) {
    return Stream<TrackingHealth>.value(health);
  }
}

class _FakeTrackingSessionRepository implements TrackingSessionRepository {
  _FakeTrackingSessionRepository({
    TrackingSessionEntity? initialSession,
    List<TrackingPointEntity>? initialPoints,
    List<SyncJobEntity>? pendingJobs,
  }) : session = initialSession,
       savedPoints = initialPoints ?? <TrackingPointEntity>[],
       _pendingJobs = pendingJobs ?? <SyncJobEntity>[];

  TrackingSessionEntity? session;
  final List<TrackingPointEntity> savedPoints;
  final List<SyncJobEntity> _pendingJobs;
  final List<TrackingSessionState> transitions = <TrackingSessionState>[];
  int _nextId = 1;

  @override
  Future<TrackingSessionEntity> createSession({
    required int raceId,
    required String role,
    required int intervalSeconds,
    required TrackingSessionState state,
    String? sensorHealthSnapshot,
  }) async {
    session = TrackingSessionEntity(
      id: _nextId++,
      raceId: raceId,
      role: role,
      state: state,
      intervalSeconds: intervalSeconds,
      startedAtUtc: DateTime.utc(2026, 4, 29, 8, 0, 0),
      sensorHealthSnapshot: sensorHealthSnapshot,
    );
    return session!;
  }

  @override
  Future<int> getPendingSyncCount({int? sessionId}) async {
    if (sessionId == null) {
      return _pendingJobs.length;
    }

    return _pendingJobs.where((job) => job.sessionId == sessionId).length;
  }

  @override
  Future<TrackingPointEntity?> loadLatestGpsPoint(int sessionId) async {
    for (final point in savedPoints.reversed) {
      if (point.sessionId == sessionId) {
        return point;
      }
    }

    return null;
  }

  @override
  Future<List<SyncJobEntity>> loadPendingSyncJobs() async => _pendingJobs;

  @override
  Future<TrackingSessionEntity?> restoreSession() async {
    final current = session;
    if (current == null) {
      return null;
    }

    if (current.state == TrackingSessionState.completed ||
        current.state == TrackingSessionState.failed ||
        current.state == TrackingSessionState.idle) {
      return null;
    }

    return current;
  }

  @override
  Future<void> saveGpsPoint(TrackingPointEntity point) async {
    savedPoints.add(point);
  }

  @override
  Future<void> queueGpsPointForSync(TrackingPointEntity point) async {}

  @override
  Future<TrackingSessionEntity> transitionSessionState({
    required int sessionId,
    required TrackingSessionState state,
    DateTime? endedAtUtc,
    String? failureReason,
    DateTime? lastSyncAtUtc,
    String? sensorHealthSnapshot,
  }) async {
    transitions.add(state);
    final current = session;
    session =
        (current ??
                TrackingSessionEntity(
                  id: sessionId,
                  raceId: 0,
                  role: 'participant',
                  state: TrackingSessionState.idle,
                  intervalSeconds: 0,
                  startedAtUtc: DateTime.utc(2026, 4, 29, 8, 0, 0),
                ))
            .copyWith(
              state: state,
              endedAtUtc: endedAtUtc,
              failureReason: failureReason,
              lastSyncAtUtc: lastSyncAtUtc,
              sensorHealthSnapshot: sensorHealthSnapshot,
            );
    return session!;
  }
}
