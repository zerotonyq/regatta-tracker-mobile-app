import 'dart:typed_data';

import '../domain/imu_sensor_event_entity.dart';

class ImuPayloadCodec {
  const ImuPayloadCodec();

  static const String sensorEventPayloadFormat = 'imu-sensor-event-le-v1';
  static const int _recordBytes = 28;

  List<ImuSensorEventEntity> decode({
    required Uint8List payload,
    required String payloadFormat,
  }) {
    if (payloadFormat != sensorEventPayloadFormat &&
        payloadFormat != 'imu-int16-le-v1') {
      throw ArgumentError.value(payloadFormat, 'payloadFormat');
    }
    if (payload.lengthInBytes % _recordBytes != 0) {
      throw ArgumentError.value(
        payload.lengthInBytes,
        'payload.lengthInBytes',
        'IMU payload must be aligned to 28-byte sensor records.',
      );
    }

    final data = ByteData.sublistView(payload);
    final events = <ImuSensorEventEntity>[];
    for (
      int offset = 0;
      offset < payload.lengthInBytes;
      offset += _recordBytes
    ) {
      final sensorTypeCode = data.getInt32(offset, Endian.little);
      final timestampNs = data.getInt64(offset + 4, Endian.little);
      final x = data.getFloat32(offset + 12, Endian.little).toDouble();
      final y = data.getFloat32(offset + 16, Endian.little).toDouble();
      final z = data.getFloat32(offset + 20, Endian.little).toDouble();
      final accuracy = data.getInt32(offset + 24, Endian.little);
      events.add(
        ImuSensorEventEntity(
          sensorType: _mapSensorType(sensorTypeCode),
          sensorTimestampNs: timestampNs,
          x: x,
          y: y,
          z: z,
          accuracy: accuracy,
        ),
      );
    }
    return events;
  }

  ImuSensorType _mapSensorType(int sensorTypeCode) {
    return switch (sensorTypeCode) {
      1 => ImuSensorType.accelerometer,
      2 => ImuSensorType.magnetometer,
      4 => ImuSensorType.gyroscope,
      _ => ImuSensorType.unknown,
    };
  }
}
