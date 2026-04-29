enum TrackingSessionState {
  idle,
  preparing,
  tracking,
  paused,
  syncing,
  completed,
  failed,
}

class TrackingSessionEntity {
  const TrackingSessionEntity({
    required this.id,
    required this.raceId,
    required this.role,
    required this.state,
    required this.intervalSeconds,
    required this.startedAtUtc,
    this.endedAtUtc,
    this.failureReason,
    this.lastSyncAtUtc,
    this.sensorHealthSnapshot,
  });

  final int id;
  final int raceId;
  final String role;
  final TrackingSessionState state;
  final int intervalSeconds;
  final DateTime startedAtUtc;
  final DateTime? endedAtUtc;
  final String? failureReason;
  final DateTime? lastSyncAtUtc;
  final String? sensorHealthSnapshot;

  TrackingSessionEntity copyWith({
    int? id,
    int? raceId,
    String? role,
    TrackingSessionState? state,
    int? intervalSeconds,
    DateTime? startedAtUtc,
    DateTime? endedAtUtc,
    String? failureReason,
    DateTime? lastSyncAtUtc,
    String? sensorHealthSnapshot,
  }) {
    return TrackingSessionEntity(
      id: id ?? this.id,
      raceId: raceId ?? this.raceId,
      role: role ?? this.role,
      state: state ?? this.state,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      endedAtUtc: endedAtUtc ?? this.endedAtUtc,
      failureReason: failureReason ?? this.failureReason,
      lastSyncAtUtc: lastSyncAtUtc ?? this.lastSyncAtUtc,
      sensorHealthSnapshot: sensorHealthSnapshot ?? this.sensorHealthSnapshot,
    );
  }
}
