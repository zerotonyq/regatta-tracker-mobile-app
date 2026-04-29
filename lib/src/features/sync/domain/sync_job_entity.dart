import 'sync_job_state.dart';
import 'sync_upload_payload.dart';

class SyncJobEntity {
  const SyncJobEntity({
    required this.id,
    required this.type,
    required this.state,
    required this.createdAtUtc,
    required this.availableAtUtc,
    this.sessionId,
    this.payloadJson,
    this.attemptCount = 0,
    this.lastError,
    this.priority = 100,
  });

  final String id;
  final String type;
  final String state;
  final DateTime createdAtUtc;
  final DateTime availableAtUtc;
  final int? sessionId;
  final String? payloadJson;
  final int attemptCount;
  final String? lastError;
  final int priority;

  SyncJobState get parsedState => syncJobStateFromWire(state);

  SyncUploadPayload? get uploadPayload {
    final raw = payloadJson;
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return SyncUploadPayload.fromJson(raw);
  }

  SyncJobEntity copyWith({
    String? id,
    String? type,
    String? state,
    DateTime? createdAtUtc,
    DateTime? availableAtUtc,
    int? sessionId,
    String? payloadJson,
    int? attemptCount,
    String? lastError,
    int? priority,
  }) {
    return SyncJobEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      state: state ?? this.state,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      availableAtUtc: availableAtUtc ?? this.availableAtUtc,
      sessionId: sessionId ?? this.sessionId,
      payloadJson: payloadJson ?? this.payloadJson,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      priority: priority ?? this.priority,
    );
  }
}
