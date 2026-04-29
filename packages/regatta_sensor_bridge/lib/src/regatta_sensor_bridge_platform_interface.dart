import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_regatta_sensor_bridge.dart';
import 'regatta_sensor_bridge_api.dart';

abstract class RegattaSensorBridgePlatform extends PlatformInterface {
  RegattaSensorBridgePlatform() : super(token: _token);

  static final Object _token = Object();

  static RegattaSensorBridgePlatform _instance =
      MethodChannelRegattaSensorBridge();

  static RegattaSensorBridgePlatform get instance => _instance;

  static set instance(RegattaSensorBridgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<SessionStatus> startTrackingSession(SessionConfig config) {
    throw UnimplementedError(
      'startTrackingSession() has not been implemented.',
    );
  }

  Future<SessionStatus> stopTrackingSession(String sessionId) {
    throw UnimplementedError('stopTrackingSession() has not been implemented.');
  }

  Future<SessionStatus> pauseTrackingSession(String sessionId) {
    throw UnimplementedError(
      'pauseTrackingSession() has not been implemented.',
    );
  }

  Future<SessionStatus> resumeTrackingSession(String sessionId) {
    throw UnimplementedError(
      'resumeTrackingSession() has not been implemented.',
    );
  }

  Future<void> setTrackingProfile(String sessionId, TrackingProfile profile) {
    throw UnimplementedError('setTrackingProfile() has not been implemented.');
  }

  Future<HealthEvent> requestRequiredPermissions() {
    throw UnimplementedError(
      'requestRequiredPermissions() has not been implemented.',
    );
  }

  Future<HealthEvent> getTrackingHealth({String? sessionId}) {
    throw UnimplementedError('getTrackingHealth() has not been implemented.');
  }

  Future<SessionStatus?> getSessionStatus(String sessionId) {
    throw UnimplementedError('getSessionStatus() has not been implemented.');
  }

  Stream<SampleBatch> streamSamples({String? sessionId}) {
    throw UnimplementedError('streamSamples() has not been implemented.');
  }

  Stream<HealthEvent> streamHealth({String? sessionId}) {
    throw UnimplementedError('streamHealth() has not been implemented.');
  }
}
