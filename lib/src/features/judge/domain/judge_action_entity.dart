class JudgeActionEntity {
  const JudgeActionEntity({
    required this.eventId,
    required this.eventType,
    required this.createdAtUtc,
    required this.syncStatus,
    this.raceId,
    this.payloadJson,
  });

  final String eventId;
  final int? raceId;
  final String eventType;
  final String? payloadJson;
  final DateTime createdAtUtc;
  final String syncStatus;
}
