import 'dart:async';

import 'package:flutter/material.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _bridge = RegattaSensorBridge();
  StreamSubscription<HealthEvent>? _healthSubscription;

  SessionStatus? _status;
  HealthEvent? _health;
  String? _error;

  @override
  void initState() {
    super.initState();
    _healthSubscription = _bridge.streamHealth().listen((HealthEvent event) {
      if (!mounted) {
        return;
      }
      setState(() {
        _health = event;
      });
    });
  }

  @override
  void dispose() {
    _healthSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startDemoSession() async {
    try {
      final status = await _bridge.startTrackingSession(
        const SessionConfig(
          sessionId: 'example-session',
          raceId: 1,
          role: 'participant',
          gpsHz: 1,
          imuHz: 50,
          desiredAccuracy: DesiredAccuracy.high,
          backgroundMode: BackgroundMode.foregroundService,
          bufferingPolicy: BufferingPolicy.persistNativeBuffer,
          initialTrackingProfile: TrackingProfile.prestartPrecision,
        ),
      );
      setState(() {
        _status = status;
        _error = null;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Sensor Bridge Example')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: _startDemoSession,
                child: const Text('Start demo session'),
              ),
              const SizedBox(height: 16),
              Text('Status: ${_status?.state.name ?? 'idle'}'),
              Text('Profile: ${_status?.activeProfile?.name ?? 'n/a'}'),
              Text(
                'Health running: '
                '${_health?.backgroundServiceRunning ?? false}',
              ),
              Text('GPS samples: ${_health?.receivedGpsSamples ?? 0}'),
              Text('IMU samples: ${_health?.receivedImuSamples ?? 0}'),
              Text('Restarts: ${_health?.serviceRestarts ?? 0}'),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
