class SessionSummaryEntity {
  const SessionSummaryEntity({
    required this.sessionId,
    required this.raceId,
    required this.role,
    required this.state,
    required this.startedAtUtc,
    required this.duration,
    required this.gpsPointCount,
    required this.imuChunkCount,
    required this.imuSampleCount,
    required this.syncState,
    required this.averageSpeedMetersPerSecond,
    required this.derivedMetricSummary,
    required this.droppedSampleCount,
    required this.hasErrors,
    this.endedAtUtc,
    this.failureReason,
    this.sensorHealthSnapshot,
    this.lastExportPath,
    this.lastExportState,
    this.lastExportedAtUtc,
  });

  final int sessionId;
  final int raceId;
  final String role;
  final String state;
  final DateTime startedAtUtc;
  final DateTime? endedAtUtc;
  final Duration duration;
  final int gpsPointCount;
  final int imuChunkCount;
  final int imuSampleCount;
  final String syncState;
  final double averageSpeedMetersPerSecond;
  final Map<String, double> derivedMetricSummary;
  final int droppedSampleCount;
  final bool hasErrors;
  final String? failureReason;
  final String? sensorHealthSnapshot;
  final String? lastExportPath;
  final String? lastExportState;
  final DateTime? lastExportedAtUtc;
}
