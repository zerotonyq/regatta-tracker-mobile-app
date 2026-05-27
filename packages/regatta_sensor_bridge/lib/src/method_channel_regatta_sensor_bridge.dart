import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'regatta_sensor_bridge_api.dart';
import 'regatta_sensor_bridge_platform_interface.dart';

class MethodChannelRegattaSensorBridge extends RegattaSensorBridgePlatform {
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel(
    'regatta_sensor_bridge/methods',
  );

  @visibleForTesting
  final EventChannel sampleChannel = const EventChannel(
    'regatta_sensor_bridge/samples',
  );

  @visibleForTesting
  final EventChannel healthChannel = const EventChannel(
    'regatta_sensor_bridge/health',
  );

  @override
  Future<SessionStatus?> getSessionStatus(String sessionId) async {
    final status = await _invokeMapMethod('getSessionStatus', <String, Object?>{
      'sessionId': sessionId,
    });
    if (status == null) {
      return null;
    }
    return SessionStatus.fromMap(status);
  }

  @override
  Future<HealthEvent> requestRequiredPermissions() async {
    final payload = await _invokeMapMethod(
      'requestRequiredPermissions',
      const <String, Object?>{},
    );
    if (payload == null) {
      throw SensorBridgeException(
        const NativeError(
          code: 'empty_response',
          message: 'requestRequiredPermissions returned no health payload.',
          isRecoverable: false,
        ),
      );
    }
    return HealthEvent.fromMap(payload);
  }

  @override
  Future<HealthEvent> getTrackingHealth({String? sessionId}) async {
    final payload = await _invokeMapMethod(
      'getTrackingHealth',
      <String, Object?>{'sessionId': sessionId},
    );
    if (payload == null) {
      throw SensorBridgeException(
        const NativeError(
          code: 'empty_response',
          message: 'getTrackingHealth returned no health payload.',
          isRecoverable: false,
        ),
      );
    }
    return HealthEvent.fromMap(payload);
  }

  @override
  Future<GpsSample> getCurrentLocation() async {
    final payload = await _invokeMapMethod(
      'getCurrentLocation',
      const <String, Object?>{},
    );
    if (payload == null) {
      throw SensorBridgeException(
        const NativeError(
          code: 'empty_response',
          message: 'getCurrentLocation returned no location payload.',
          isRecoverable: true,
        ),
      );
    }
    return GpsSample.fromMap(payload);
  }

  @override
  Future<SessionStatus> pauseTrackingSession(String sessionId) async {
    final status = await _invokeMapMethod(
      'pauseTrackingSession',
      <String, Object?>{'sessionId': sessionId},
    );
    return _requireStatus(status, 'pauseTrackingSession');
  }

  @override
  Future<SessionStatus> resumeTrackingSession(String sessionId) async {
    final status = await _invokeMapMethod(
      'resumeTrackingSession',
      <String, Object?>{'sessionId': sessionId},
    );
    return _requireStatus(status, 'resumeTrackingSession');
  }

  @override
  Future<void> setTrackingProfile(
    String sessionId,
    TrackingProfile profile,
  ) async {
    try {
      await methodChannel.invokeMethod<void>(
        'setTrackingProfile',
        <String, Object?>{'sessionId': sessionId, 'profile': profile.name},
      );
    } on PlatformException catch (error) {
      throw _mapPlatformException(error);
    }
  }

  @override
  Future<SessionStatus> startTrackingSession(SessionConfig config) async {
    final status = await _invokeMapMethod(
      'startTrackingSession',
      config.toMap(),
    );
    return _requireStatus(status, 'startTrackingSession');
  }

  @override
  Future<SessionStatus> stopTrackingSession(String sessionId) async {
    final status = await _invokeMapMethod(
      'stopTrackingSession',
      <String, Object?>{'sessionId': sessionId},
    );
    return _requireStatus(status, 'stopTrackingSession');
  }

  @override
  Stream<HealthEvent> streamHealth({String? sessionId}) {
    return healthChannel
        .receiveBroadcastStream(<String, Object?>{'sessionId': sessionId})
        .map((Object? event) {
          return HealthEvent.fromMap(event as Map<Object?, Object?>);
        });
  }

  @override
  Stream<SampleBatch> streamSamples({String? sessionId}) {
    return sampleChannel
        .receiveBroadcastStream(<String, Object?>{'sessionId': sessionId})
        .map((Object? event) {
          return SampleBatch.fromMap(event as Map<Object?, Object?>);
        });
  }

  SessionStatus _requireStatus(
    Map<Object?, Object?>? payload,
    String methodName,
  ) {
    if (payload == null) {
      throw SensorBridgeException(
        NativeError(
          code: 'empty_response',
          message: '$methodName returned no session status payload.',
          isRecoverable: false,
        ),
      );
    }
    return SessionStatus.fromMap(payload);
  }

  Future<Map<Object?, Object?>?> _invokeMapMethod(
    String method,
    Map<String, Object?> arguments,
  ) async {
    try {
      return await methodChannel.invokeMapMethod<Object?, Object?>(
        method,
        arguments,
      );
    } on PlatformException catch (error) {
      throw _mapPlatformException(error);
    }
  }

  SensorBridgeException _mapPlatformException(PlatformException error) {
    final details = error.details;
    final recoverable =
        details is Map<Object?, Object?> && details['isRecoverable'] is bool
        ? details['isRecoverable'] as bool
        : false;
    return SensorBridgeException(
      NativeError(
        code: error.code,
        message: error.message ?? 'Native bridge call failed.',
        isRecoverable: recoverable,
      ),
    );
  }
}
