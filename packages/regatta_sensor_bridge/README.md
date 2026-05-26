# regatta_sensor_bridge

Local Flutter plugin scaffold for the regatta tracking bridge between Dart and native Android/iOS code.

## API surface

The plugin exposes a single formal bridge contract:

- `startTrackingSession`
- `stopTrackingSession`
- `pauseTrackingSession`
- `resumeTrackingSession`
- `setTrackingProfile`
- `getSessionStatus`
- `streamSamples`
- `streamHealth`

Core DTOs are implemented in Dart and shared by both the app and plugin tests:

- `SessionConfig`
- `SessionStatus`
- `SampleBatch`
- `HealthEvent`
- `NativeError`

Tracking profiles are fixed at this stage:

- `prestartPrecision`
- `raceCruise`
- `markRoundingPrecision`
- `paused`

## Production decisions

- `sessionId` ownership stays on the Flutter side for now. The app creates the local tracking session first, then passes its id into the bridge as a string.
- The bridge uses native buffering for background collection and streams lightweight notifications with GPS samples and IMU chunk references to Flutter.
- Desktop, web, and unit tests use `FakeRegattaSensorBridgePlatform`, while Android/iOS receive a method-channel stub that already speaks the same contract.

## Current state

This package now contains production-oriented mobile collectors plus a fake implementation for tests:

- Android runs a foreground service, requests high-accuracy fused location updates at 1 Hz, records accelerometer/gyroscope/magnetometer events, writes GPS NDJSON and 1-second IMU binary chunks, and emits health/rate diagnostics.
- iOS uses `CLLocationManager` and `CMMotionManager`, enables background location mode in the host app, records GPS NDJSON and 1-second IMU binary chunks, and emits the same health/sample contract.
- `averageImuRateHz` is reported as a per-sensor rate. `receivedImuSamples` and IMU chunk `sampleCount` are event counts, because accelerometer, gyroscope, and magnetometer events can arrive independently.
- Flutter imports native chunk references into Drift/SQLite and keeps SQLite as the authoritative application cache for sync, export, and analysis.
