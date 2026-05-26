import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sensor bridge contract supports lifecycle, health and samples', (
    tester,
  ) async {
    final platform = FakeRegattaSensorBridgePlatform();
    final bridge = RegattaSensorBridge(platform: platform);
    final config = SessionConfig(
      sessionId: 'contract-1',
      raceId: 42,
      role: 'participant',
      gpsHz: 1,
      imuHz: 50,
      desiredAccuracy: DesiredAccuracy.high,
      backgroundMode: BackgroundMode.foregroundService,
      bufferingPolicy: BufferingPolicy.persistNativeBuffer,
      initialTrackingProfile: TrackingProfile.prestartPrecision,
    );

    final status = await bridge.startTrackingSession(config);
    expect(status.state, SessionLifecycleState.tracking);

    final health = await bridge.getTrackingHealth(sessionId: config.sessionId);
    expect(health.backgroundServiceRunning, isTrue);
    expect(health.targetGpsHz, 1);
    expect(health.targetImuHz, 50);

    final sampleFuture = bridge
        .streamSamples(sessionId: config.sessionId)
        .first;
    platform.emitSampleBatch(
      SampleBatch(
        sessionId: config.sessionId,
        recordedAt: DateTime.utc(2026, 4, 29, 12),
        gpsPoints: <GpsSample>[
          GpsSample(
            timestamp: DateTime.utc(2026, 4, 29, 12),
            longitude: 30,
            latitude: 60,
            accuracyMeters: 3,
            speedMetersPerSecond: 4,
          ),
        ],
        imuChunkRefs: <ImuChunkRef>[
          ImuChunkRef(
            chunkId: 'imu-1',
            startedAt: DateTime.utc(2026, 4, 29, 12),
            sampleCount: 150,
            storagePath: '/tmp/imu-1.bin',
          ),
        ],
      ),
    );

    final sample = await sampleFuture;
    expect(sample.gpsPoints, hasLength(1));
    expect(sample.imuChunkRefs.single.sampleCount, 150);

    final paused = await bridge.pauseTrackingSession(config.sessionId);
    expect(paused.state, SessionLifecycleState.paused);
    final resumed = await bridge.resumeTrackingSession(config.sessionId);
    expect(resumed.state, SessionLifecycleState.tracking);
    final stopped = await bridge.stopTrackingSession(config.sessionId);
    expect(stopped.state, SessionLifecycleState.stopped);
  });
}
