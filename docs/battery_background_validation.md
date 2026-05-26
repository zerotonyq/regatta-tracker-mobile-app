# Battery and Background Validation

## Goal

Validate that regatta tracking can run in the background without falling below
the required sensor rates or causing unacceptable battery drain.

## Manual Acceptance Scenario

1. Install a debug or profile build on a physical Android or iOS device.
2. Grant location, background location, notification, and motion permissions.
3. Start participant tracking for an active race and leave the app in the
   background for 10-15 minutes.
4. Reopen the app and export the session diagnostics bundle.
5. Accept the run only if:
   - `averageGpsRateHz >= 1.0` after the first warm-up minute.
   - `averageImuRateHz >= 50.0` per sensor after the first warm-up minute.
   - `droppedSamples` does not grow continuously.
   - `backgroundServiceRunning` remains true while tracking is active.
   - `serviceRestarts` is documented if the OS restarts collection.
   - Battery delta is recorded from the diagnostics health snapshots.

## Diagnostics to Capture

- Device model, OS version, app version, tracking profile, and permission state.
- Battery percentage at start/end.
- GPS and IMU target rates versus actual rates.
- Last GPS/IMU sample age.
- Dropped samples and native storage path.
- SQLite export manifest and diagnostics JSON.

## Notes

Android uses a foreground service with a persistent notification. iOS uses
background location mode and motion updates while the process is active; iOS can
still suspend work under thermal or battery pressure, so the diagnostics export
must be attached to every long-run validation.
