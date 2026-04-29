class DiagnosticsSnapshotEntity {
  const DiagnosticsSnapshotEntity({
    required this.generatedAtUtc,
    required this.appVersion,
    required this.databaseSchemaVersion,
    required this.locationPermission,
    required this.motionPermission,
    required this.gpsEnabled,
    required this.imuEnabled,
    required this.backgroundServiceRunning,
    required this.averageGpsRateHz,
    required this.averageImuRateHz,
    required this.droppedSamples,
    required this.syncLagSeconds,
    required this.pendingSyncJobs,
    required this.batteryImpactMarkers,
    required this.sensorHealthSnapshot,
    this.sessionId,
  });

  final DateTime generatedAtUtc;
  final String appVersion;
  final int databaseSchemaVersion;
  final String locationPermission;
  final String motionPermission;
  final bool gpsEnabled;
  final bool imuEnabled;
  final bool backgroundServiceRunning;
  final double averageGpsRateHz;
  final double averageImuRateHz;
  final int droppedSamples;
  final int syncLagSeconds;
  final int pendingSyncJobs;
  final List<String> batteryImpactMarkers;
  final String sensorHealthSnapshot;
  final int? sessionId;
}
