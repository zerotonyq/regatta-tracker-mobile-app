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
    this.targetGpsHz,
    this.targetImuHz,
    this.averageGpsRateHz,
    this.averageImuRateHz,
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
  final double? targetGpsHz;
  final double? targetImuHz;
  final double? averageGpsRateHz;
  final double? averageImuRateHz;
  final int pendingSyncCount;
  final int droppedSampleCount;
  final TrackingProfile? activeTrackingProfile;

  bool get canStartTracking =>
      locationPermission == TrackingPermissionState.granted && gpsEnabled;

  bool get gpsRateBelowTarget =>
      backgroundServiceRunning &&
      targetGpsHz != null &&
      averageGpsRateHz != null &&
      averageGpsRateHz! < targetGpsHz!;

  bool get imuRateBelowTarget =>
      backgroundServiceRunning &&
      targetImuHz != null &&
      averageImuRateHz != null &&
      averageImuRateHz! < targetImuHz!;

  bool get hasTelemetryWarning => gpsRateBelowTarget || imuRateBelowTarget;

  TrackingHealth copyWith({
    TrackingPermissionState? locationPermission,
    TrackingPermissionState? motionPermission,
    bool? gpsEnabled,
    bool? imuEnabled,
    bool? backgroundServiceRunning,
    double? gpsAccuracyMeters,
    int? lastGpsSampleAgeMs,
    int? lastImuSampleAgeMs,
    double? targetGpsHz,
    double? targetImuHz,
    double? averageGpsRateHz,
    double? averageImuRateHz,
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
      targetGpsHz: targetGpsHz ?? this.targetGpsHz,
      targetImuHz: targetImuHz ?? this.targetImuHz,
      averageGpsRateHz: averageGpsRateHz ?? this.averageGpsRateHz,
      averageImuRateHz: averageImuRateHz ?? this.averageImuRateHz,
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
