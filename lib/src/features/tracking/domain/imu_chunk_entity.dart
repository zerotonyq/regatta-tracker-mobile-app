import 'dart:typed_data';

class ImuChunkEntity {
  const ImuChunkEntity({
    this.id,
    required this.sessionId,
    required this.capturedAtUtc,
    required this.chunkStartMonotonicNs,
    required this.sampleCount,
    required this.samplingHz,
    required this.payload,
    this.payloadFormat = 'imu-int16-le-v1',
  });

  final int? id;
  final int sessionId;
  final DateTime capturedAtUtc;
  final int chunkStartMonotonicNs;
  final int sampleCount;
  final int samplingHz;
  final Uint8List payload;
  final String payloadFormat;
}
