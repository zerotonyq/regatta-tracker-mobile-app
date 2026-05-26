# Sensor Fusion Filter Notes

## Current Algorithm

The mobile client uses a complementary filter for orientation and race metrics.
Gyroscope integration provides short-term responsiveness, while accelerometer
roll/pitch and magnetometer heading corrections reduce drift over time. GPS
course-over-ground is used only when the boat is moving fast enough to make the
course meaningful.

## Why Complementary Filter for This Version

- It is deterministic, lightweight, and suitable for 50 Hz mobile IMU updates.
- It can run in a Dart isolate after each native IMU chunk without blocking UI.
- It exposes clear quality flags for stale GPS, magnetic instability, missing
  calibration, insufficient samples, and GPS heading validation.

## Kalman Filter Comparison Work

A Kalman filter remains the primary research comparison candidate. It may improve
drift handling and uncertainty modeling, but it also needs a stronger motion
model, noise covariance tuning, and more field data from yacht maneuvers.

## Validation Cases

The test suite covers stable heading/heel, gyro bias calibration, magnetic
instability, stale or missing GPS context, low-speed GPS rejection, malformed
payloads, and persistence of derived metrics after native chunk ingestion.
