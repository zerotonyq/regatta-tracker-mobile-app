import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelRegattaSensorBridge();
  const channel = MethodChannel('regatta_sensor_bridge/methods');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return <String, Object?>{
            'state': 'tracking',
            'sessionId': 'session-1',
            'startedAt': DateTime.utc(2026, 4, 29, 12).toIso8601String(),
            'activeProfile': 'prestartPrecision',
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('startTrackingSession decodes native status payload', () async {
    final status = await platform.startTrackingSession(
      const SessionConfig(
        sessionId: 'session-1',
        raceId: 1,
        role: 'participant',
        gpsHz: 1,
        imuHz: 50,
        desiredAccuracy: DesiredAccuracy.high,
        backgroundMode: BackgroundMode.foregroundService,
        bufferingPolicy: BufferingPolicy.streamToFlutter,
        initialTrackingProfile: TrackingProfile.prestartPrecision,
      ),
    );

    expect(status.sessionId, 'session-1');
    expect(status.state, SessionLifecycleState.tracking);
  });
}
