import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

enum TrackingPermissionState { granted, denied, deniedForever, unknown }

class TrackingHealth {
  const TrackingHealth({
    required this.locationPermission,
    required this.motionPermission,
    required this.gpsEnabled,
    required this.imuEnabled,
    required this.backgroundServiceRunning,
    required this.pendingSyncCount,
    required this.droppedSampleCount,
    this.gpsAccuracyMeters,
    this.lastGpsSampleAgeMs,
    this.lastImuSampleAgeMs,
    this.activeTrackingProfile,
  });

  final TrackingPermissionState locationPermission;
  final TrackingPermissionState motionPermission;
  final bool gpsEnabled;
  final bool imuEnabled;
  final bool backgroundServiceRunning;
  final double? gpsAccuracyMeters;
  final int? lastGpsSampleAgeMs;
  final int? lastImuSampleAgeMs;
  final int pendingSyncCount;
  final int droppedSampleCount;
  final TrackingProfile? activeTrackingProfile;

  bool get canStartTracking =>
      locationPermission == TrackingPermissionState.granted && gpsEnabled;

  TrackingHealth copyWith({
    TrackingPermissionState? locationPermission,
    TrackingPermissionState? motionPermission,
    bool? gpsEnabled,
    bool? imuEnabled,
    bool? backgroundServiceRunning,
    double? gpsAccuracyMeters,
    int? lastGpsSampleAgeMs,
    int? lastImuSampleAgeMs,
    int? pendingSyncCount,
    int? droppedSampleCount,
    TrackingProfile? activeTrackingProfile,
  }) {
    return TrackingHealth(
      locationPermission: locationPermission ?? this.locationPermission,
      motionPermission: motionPermission ?? this.motionPermission,
      gpsEnabled: gpsEnabled ?? this.gpsEnabled,
      imuEnabled: imuEnabled ?? this.imuEnabled,
      backgroundServiceRunning:
          backgroundServiceRunning ?? this.backgroundServiceRunning,
      gpsAccuracyMeters: gpsAccuracyMeters ?? this.gpsAccuracyMeters,
      lastGpsSampleAgeMs: lastGpsSampleAgeMs ?? this.lastGpsSampleAgeMs,
      lastImuSampleAgeMs: lastImuSampleAgeMs ?? this.lastImuSampleAgeMs,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      droppedSampleCount: droppedSampleCount ?? this.droppedSampleCount,
      activeTrackingProfile:
          activeTrackingProfile ?? this.activeTrackingProfile,
    );
  }

  static const unknown = TrackingHealth(
    locationPermission: TrackingPermissionState.unknown,
    motionPermission: TrackingPermissionState.unknown,
    gpsEnabled: false,
    imuEnabled: false,
    backgroundServiceRunning: false,
    pendingSyncCount: 0,
    droppedSampleCount: 0,
  );
}
