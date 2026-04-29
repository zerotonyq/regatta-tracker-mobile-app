import 'package:flutter_test/flutter_test.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRegattaSensorBridgePlatform
    with MockPlatformInterfaceMixin
    implements RegattaSensorBridgePlatform {
  @override
  Future<SessionStatus> startTrackingSession(SessionConfig config) async {
    return SessionStatus(
      state: SessionLifecycleState.tracking,
      sessionId: config.sessionId,
      startedAt: DateTime.utc(2026, 4, 29, 12),
      activeProfile: config.initialTrackingProfile,
    );
  }

  @override
  Future<SessionStatus?> getSessionStatus(String sessionId) async {
    return SessionStatus(
      state: SessionLifecycleState.tracking,
      sessionId: sessionId,
      startedAt: DateTime.utc(2026, 4, 29, 12),
      activeProfile: TrackingProfile.raceCruise,
    );
  }

  @override
  Future<SessionStatus> pauseTrackingSession(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionStatus> resumeTrackingSession(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<void> setTrackingProfile(String sessionId, TrackingProfile profile) {
    throw UnimplementedError();
  }

  @override
  Future<HealthEvent> requestRequiredPermissions() async {
    return _healthEvent();
  }

  @override
  Future<HealthEvent> getTrackingHealth({String? sessionId}) async {
    return _healthEvent(sessionId: sessionId);
  }

  @override
  Future<SessionStatus> stopTrackingSession(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Stream<HealthEvent> streamHealth({String? sessionId}) {
    return Stream<HealthEvent>.value(_healthEvent(sessionId: sessionId));
  }

  @override
  Stream<SampleBatch> streamSamples({String? sessionId}) {
    return const Stream<SampleBatch>.empty();
  }

  HealthEvent _healthEvent({String? sessionId}) {
    return HealthEvent(
      sessionId: sessionId,
      recordedAt: DateTime.utc(2026, 4, 29, 12),
      locationPermission: PermissionStatus.granted,
      motionPermission: PermissionStatus.unknown,
      gpsAvailable: true,
      imuAvailable: false,
      backgroundServiceRunning: true,
      droppedSamples: 0,
      queueDepth: 0,
    );
  }
}

void main() {
  final RegattaSensorBridgePlatform initialPlatform =
      RegattaSensorBridgePlatform.instance;

  test('$MethodChannelRegattaSensorBridge is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRegattaSensorBridge>());
  });

  test('startTrackingSession delegates to platform instance', () async {
    final fakePlatform = MockRegattaSensorBridgePlatform();
    RegattaSensorBridgePlatform.instance = fakePlatform;
    final regattaSensorBridgePlugin = RegattaSensorBridge();

    final status = await regattaSensorBridgePlugin.startTrackingSession(
      const SessionConfig(
        sessionId: 'session-42',
        raceId: 42,
        role: 'participant',
        gpsHz: 1,
        imuHz: 50,
        desiredAccuracy: DesiredAccuracy.high,
        backgroundMode: BackgroundMode.foregroundService,
        bufferingPolicy: BufferingPolicy.streamToFlutter,
        initialTrackingProfile: TrackingProfile.prestartPrecision,
      ),
    );

    expect(status.sessionId, 'session-42');
    expect(status.state, SessionLifecycleState.tracking);
  });
}
