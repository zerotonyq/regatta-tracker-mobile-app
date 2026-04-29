import CoreLocation
import CoreMotion
import Flutter
import UIKit
import UserNotifications

public class RegattaSensorBridgePlugin: NSObject, FlutterPlugin {
  private var activeSession: [String: Any?]?
  private var healthSink: FlutterEventSink?
  private var pendingPermissionResult: FlutterResult?
  private var pendingPermissionTasks = 0
  private var locationManager: CLLocationManager?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = RegattaSensorBridgePlugin()
    let methodChannel = FlutterMethodChannel(
      name: "regatta_sensor_bridge/methods",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let sampleChannel = FlutterEventChannel(
      name: "regatta_sensor_bridge/samples",
      binaryMessenger: registrar.messenger()
    )
    sampleChannel.setStreamHandler(EmptyStreamHandler())

    let healthChannel = FlutterEventChannel(
      name: "regatta_sensor_bridge/health",
      binaryMessenger: registrar.messenger()
    )
    healthChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any?] ?? [:]

    switch call.method {
    case "startTrackingSession":
      let sessionId = arguments["sessionId"] as? String ?? "unknown"
      activeSession = [
        "state": "tracking",
        "sessionId": sessionId,
        "startedAt": isoNow(),
        "lastSampleAt": isoNow(),
        "activeProfile": arguments["initialTrackingProfile"] as? String ?? "prestartPrecision",
        "error": nil,
      ]
      emitHealth(sessionId: sessionId, isRunning: true, statusMessage: "Tracking active.")
      result(activeSession)
    case "stopTrackingSession":
      activeSession = updateSession(state: "stopped", profile: "paused")
      emitHealth(
        sessionId: activeSession?["sessionId"] as? String,
        isRunning: false,
        statusMessage: "Tracking stopped."
      )
      result(activeSession)
    case "pauseTrackingSession":
      activeSession = updateSession(state: "paused", profile: "paused")
      activeSession?["pausedAt"] = isoNow()
      emitHealth(
        sessionId: activeSession?["sessionId"] as? String,
        isRunning: false,
        statusMessage: "Tracking paused."
      )
      result(activeSession)
    case "resumeTrackingSession":
      activeSession = updateSession(state: "tracking", profile: "raceCruise")
      activeSession?["pausedAt"] = nil
      emitHealth(
        sessionId: activeSession?["sessionId"] as? String,
        isRunning: true,
        statusMessage: "Tracking active."
      )
      result(activeSession)
    case "setTrackingProfile":
      activeSession?["activeProfile"] = arguments["profile"] as? String
      result(nil)
    case "requestRequiredPermissions":
      requestRequiredPermissions(result: result)
    case "getTrackingHealth":
      result(
        buildHealth(
          sessionId: arguments["sessionId"] as? String ?? activeSession?["sessionId"] as? String,
          isRunning: activeSession?["state"] as? String == "tracking",
          statusMessage: "Health snapshot requested."
        )
      )
    case "getSessionStatus":
      result(activeSession)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestRequiredPermissions(result: @escaping FlutterResult) {
    guard pendingPermissionResult == nil else {
      result(
        FlutterError(
          code: "permission_request_in_progress",
          message: "A runtime permission request is already in progress.",
          details: ["isRecoverable": true]
        )
      )
      return
    }

    pendingPermissionResult = result
    pendingPermissionTasks = 0

    requestLocationPermissionIfNeeded()
    requestMotionPermissionIfNeeded()
    requestNotificationPermissionIfNeeded()
    finishPermissionRequestIfPossible()
  }

  private func requestLocationPermissionIfNeeded() {
    let status: CLAuthorizationStatus
    if #available(iOS 14.0, *) {
      status = CLLocationManager().authorizationStatus
    } else {
      status = CLLocationManager.authorizationStatus()
    }

    guard status == .notDetermined else {
      return
    }

    pendingPermissionTasks += 1
    let manager = CLLocationManager()
    manager.delegate = self
    locationManager = manager
    if Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil {
      manager.requestAlwaysAuthorization()
    } else {
      manager.requestWhenInUseAuthorization()
    }
  }

  private func requestMotionPermissionIfNeeded() {
    guard CMMotionActivityManager.isActivityAvailable() else {
      return
    }

    if #available(iOS 11.0, *) {
      let status = CMMotionActivityManager.authorizationStatus()
      guard status == .notDetermined else {
        return
      }
    }

    pendingPermissionTasks += 1
    let now = Date()
    CMMotionActivityManager().queryActivityStarting(
      from: now.addingTimeInterval(-60),
      to: now,
      to: .main
    ) { [weak self] _, _ in
      self?.completePermissionTask()
    }
  }

  private func requestNotificationPermissionIfNeeded() {
    guard #available(iOS 10.0, *) else {
      return
    }

    UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
      guard let self else {
        return
      }

      guard settings.authorizationStatus == .notDetermined else {
        return
      }

      self.pendingPermissionTasks += 1
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
        [weak self] _, _ in
        DispatchQueue.main.async {
          self?.completePermissionTask()
        }
      }
    }
  }

  private func completePermissionTask() {
    pendingPermissionTasks = max(0, pendingPermissionTasks - 1)
    finishPermissionRequestIfPossible()
  }

  private func finishPermissionRequestIfPossible() {
    guard pendingPermissionTasks == 0, let result = pendingPermissionResult else {
      return
    }

    pendingPermissionResult = nil
    let payload = buildHealth(
      sessionId: activeSession?["sessionId"] as? String,
      isRunning: activeSession?["state"] as? String == "tracking",
      statusMessage: "Runtime permissions updated."
    )
    healthSink?(payload)
    result(payload)
  }

  private func updateSession(state: String, profile: String) -> [String: Any?] {
    var session = activeSession ?? [
      "state": state,
      "sessionId": "unknown",
      "startedAt": isoNow(),
      "activeProfile": profile,
      "error": nil,
    ]
    session["state"] = state
    session["activeProfile"] = profile
    return session
  }

  private func emitHealth(sessionId: String?, isRunning: Bool, statusMessage: String) {
    let payload = buildHealth(
      sessionId: sessionId,
      isRunning: isRunning,
      statusMessage: statusMessage
    )
    healthSink?(payload)
  }

  private func buildHealth(
    sessionId: String?,
    isRunning: Bool? = nil,
    statusMessage: String
  ) -> [String: Any?] {
    return [
      "sessionId": sessionId,
      "recordedAt": isoNow(),
      "locationPermission": mapLocationPermissionStatus(),
      "motionPermission": mapMotionPermissionStatus(),
      "gpsAvailable": CLLocationManager.locationServicesEnabled(),
      "imuAvailable": CMMotionManager().isAccelerometerAvailable && CMMotionManager().isGyroAvailable,
      "backgroundServiceRunning": isRunning ?? (activeSession?["state"] as? String == "tracking"),
      "droppedSamples": 0,
      "queueDepth": 0,
      "batteryPercent": nil,
      "lastGpsSampleAgeMs": 0,
      "lastImuSampleAgeMs": nil,
      "gpsAccuracyMeters": nil,
      "receivedGpsSamples": 0,
      "receivedImuSamples": 0,
      "averageGpsRateHz": nil,
      "averageImuRateHz": nil,
      "lastGpsSensorTimestamp": nil,
      "lastImuSensorTimestamp": nil,
      "serviceRestarts": 0,
      "activeTrackingProfile": activeSession?["activeProfile"] as? String,
      "statusMessage": statusMessage,
      "storagePath": nil,
      "error": nil,
    ]
  }

  private func mapLocationPermissionStatus() -> String {
    let status: CLAuthorizationStatus
    if #available(iOS 14.0, *) {
      status = CLLocationManager().authorizationStatus
    } else {
      status = CLLocationManager.authorizationStatus()
    }

    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      return "granted"
    case .denied:
      return "denied"
    case .restricted:
      return "deniedForever"
    case .notDetermined:
      return "unknown"
    @unknown default:
      return "unknown"
    }
  }

  private func mapMotionPermissionStatus() -> String {
    guard #available(iOS 11.0, *) else {
      return "unknown"
    }

    switch CMMotionActivityManager.authorizationStatus() {
    case .authorized:
      return "granted"
    case .denied:
      return "denied"
    case .restricted:
      return "deniedForever"
    case .notDetermined:
      return "unknown"
    @unknown default:
      return "unknown"
    }
  }

  private func isoNow() -> String {
    ISO8601DateFormatter().string(from: Date())
  }
}

extension RegattaSensorBridgePlugin: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    healthSink = events
    events(
      buildHealth(
        sessionId: activeSession?["sessionId"] as? String,
        statusMessage: "Sensor bridge idle."
      )
    )
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    healthSink = nil
    return nil
  }
}

extension RegattaSensorBridgePlugin: CLLocationManagerDelegate {
  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if #available(iOS 14.0, *) {
      guard manager.authorizationStatus != .notDetermined else {
        return
      }
    }
    locationManager = nil
    completePermissionTask()
  }

  public func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    guard status != .notDetermined else {
      return
    }
    locationManager = nil
    completePermissionTask()
  }
}

private final class EmptyStreamHandler: NSObject, FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return nil
  }
}
