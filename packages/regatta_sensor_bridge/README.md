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

## Decisions fixed in step 06

- `sessionId` ownership stays on the Flutter side for now. The app creates the local tracking session first, then passes its id into the bridge as a string.
- The bridge boundary is already shaped for future native buffering and background collection, but step 06 still keeps durable track storage in the Flutter app database.
- Desktop, web, and unit tests use `FakeRegattaSensorBridgePlatform`, while Android/iOS receive a method-channel stub that already speaks the same contract.

## Current state

This package is intentionally a scaffold, not a production sensor implementation yet:

- Android and iOS return in-memory stub status/health payloads.
- Sample streaming is wired structurally, but native sample capture is not implemented in this step.
- The app-side repository and tracking controller are already integrated against the abstraction so steps 07 and 08 can focus on platform work without reshaping Flutter code again.
