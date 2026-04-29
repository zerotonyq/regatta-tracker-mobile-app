import 'dart:convert';

import '../../tracking/domain/tracking_point_entity.dart';

class SyncUploadPayload {
  const SyncUploadPayload({
    required this.clientTaskId,
    required this.sessionId,
    required this.timestampUtc,
    required this.longitude,
    required this.latitude,
    this.accuracyMeters,
    this.speedMetersPerSecond,
  });

  final String clientTaskId;
  final int sessionId;
  final DateTime timestampUtc;
  final double longitude;
  final double latitude;
  final double? accuracyMeters;
  final double? speedMetersPerSecond;

  factory SyncUploadPayload.fromTrackingPoint({
    required TrackingPointEntity point,
    required String clientTaskId,
  }) {
    return SyncUploadPayload(
      clientTaskId: clientTaskId,
      sessionId: point.sessionId!,
      timestampUtc: point.timestampUtc.toUtc(),
      longitude: point.longitude,
      latitude: point.latitude,
      accuracyMeters: point.accuracyMeters,
      speedMetersPerSecond: point.speedMetersPerSecond,
    );
  }

  factory SyncUploadPayload.fromJson(String payloadJson) {
    final Map<String, Object?> map = Map<String, Object?>.from(
      jsonDecode(payloadJson) as Map,
    );
    return SyncUploadPayload(
      clientTaskId: map['client_task_id'] as String,
      sessionId: (map['session_id'] as num).toInt(),
      timestampUtc: DateTime.parse(map['timestamp_utc'] as String).toUtc(),
      longitude: (map['longitude'] as num).toDouble(),
      latitude: (map['latitude'] as num).toDouble(),
      accuracyMeters: (map['accuracy_meters'] as num?)?.toDouble(),
      speedMetersPerSecond: (map['speed_meters_per_second'] as num?)
          ?.toDouble(),
    );
  }

  String toJson() {
    return jsonEncode(<String, Object?>{
      'client_task_id': clientTaskId,
      'session_id': sessionId,
      'timestamp_utc': timestampUtc.toUtc().toIso8601String(),
      'longitude': longitude,
      'latitude': latitude,
      'accuracy_meters': accuracyMeters,
      'speed_meters_per_second': speedMetersPerSecond,
    });
  }
}
