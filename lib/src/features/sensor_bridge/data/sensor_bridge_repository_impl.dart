import 'dart:async';

import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

import '../../tracking/domain/tracking_health.dart';
import '../domain/sensor_bridge_repository.dart';

class SensorBridgeRepositoryImpl implements SensorBridgeRepository {
  SensorBridgeRepositoryImpl({RegattaSensorBridge? bridge})
    : _bridge = bridge ?? RegattaSensorBridge();

  final RegattaSensorBridge _bridge;

  @override
  Future<SessionStatus?> getSessionStatus({required String sessionId}) {
    return _bridge.getSessionStatus(sessionId);
  }

  @override
  Future<TrackingHealth> requestRequiredPermissions() async {
    final event = await _bridge.requestRequiredPermissions();
    return _mapHealth(event);
  }

  @override
  Future<SessionStatus> pauseTrackingSession({required String sessionId}) {
    return _bridge.pauseTrackingSession(sessionId);
  }

  @override
  Future<TrackingHealth> readTrackingHealth({String? sessionId}) async {
    try {
      final event = await _bridge
          .getTrackingHealth(sessionId: sessionId)
          .timeout(const Duration(milliseconds: 250));
      return _mapHealth(event);
    } on TimeoutException {
      return TrackingHealth.unknown;
    }
  }

  @override
  Future<GpsSample> getCurrentLocation() {
    return _bridge.getCurrentLocation();
  }

  @override
  Future<SessionStatus> resumeTrackingSession({required String sessionId}) {
    return _bridge.resumeTrackingSession(sessionId);
  }

  @override
  Future<void> setTrackingProfile({
    required String sessionId,
    required TrackingProfile profile,
  }) {
    return _bridge.setTrackingProfile(sessionId, profile);
  }

  @override
  Future<SessionStatus> startTrackingSession({required SessionConfig config}) {
    return _bridge.startTrackingSession(config);
  }

  @override
  Future<SessionStatus> stopTrackingSession({required String sessionId}) {
    return _bridge.stopTrackingSession(sessionId);
  }

  @override
  Stream<HealthEvent> streamHealth({String? sessionId}) {
    return _bridge.streamHealth(sessionId: sessionId);
  }

  @override
  Stream<SampleBatch> streamSamples({String? sessionId}) {
    return _bridge.streamSamples(sessionId: sessionId);
  }

  @override
  Stream<TrackingHealth> watchTrackingHealth({String? sessionId}) {
    return streamHealth(sessionId: sessionId).map(_mapHealth);
  }

  TrackingHealth _mapHealth(HealthEvent event) {
    return TrackingHealth(
      locationPermission: _mapPermission(event.locationPermission),
      motionPermission: _mapPermission(event.motionPermission),
      gpsEnabled: event.gpsAvailable,
      imuEnabled: event.imuAvailable,
      backgroundServiceRunning: event.backgroundServiceRunning,
      gpsAccuracyMeters: event.gpsAccuracyMeters,
      lastGpsSampleAgeMs: event.lastGpsSampleAgeMs,
      lastImuSampleAgeMs: event.lastImuSampleAgeMs,
      targetGpsHz: event.targetGpsHz,
      targetImuHz: event.targetImuHz,
      averageGpsRateHz: event.averageGpsRateHz,
      averageImuRateHz: event.averageImuRateHz,
      pendingSyncCount: event.queueDepth,
      droppedSampleCount: event.droppedSamples,
      activeTrackingProfile: event.activeTrackingProfile,
    );
  }

  TrackingPermissionState _mapPermission(PermissionStatus permission) {
    return switch (permission) {
      PermissionStatus.granted => TrackingPermissionState.granted,
      PermissionStatus.denied => TrackingPermissionState.denied,
      PermissionStatus.deniedForever => TrackingPermissionState.deniedForever,
      PermissionStatus.unknown => TrackingPermissionState.unknown,
    };
  }
}
