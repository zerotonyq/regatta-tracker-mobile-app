import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

import '../../tracking/domain/tracking_health.dart';

abstract class SensorBridgeRepository {
  Future<TrackingHealth> requestRequiredPermissions();

  Future<TrackingHealth> readTrackingHealth({String? sessionId});

  Future<GpsSample> getCurrentLocation();

  Stream<TrackingHealth> watchTrackingHealth({String? sessionId});

  Future<SessionStatus> startTrackingSession({required SessionConfig config});

  Future<SessionStatus> stopTrackingSession({required String sessionId});

  Future<SessionStatus> pauseTrackingSession({required String sessionId});

  Future<SessionStatus> resumeTrackingSession({required String sessionId});

  Future<void> setTrackingProfile({
    required String sessionId,
    required TrackingProfile profile,
  });

  Future<SessionStatus?> getSessionStatus({required String sessionId});

  Stream<SampleBatch> streamSamples({String? sessionId});

  Stream<HealthEvent> streamHealth({String? sessionId});
}
