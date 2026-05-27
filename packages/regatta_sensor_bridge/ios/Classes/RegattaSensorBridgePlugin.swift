import CoreLocation
import CoreMotion
import Flutter
import UIKit
import UserNotifications

public class RegattaSensorBridgePlugin: NSObject, FlutterPlugin {
  private var activeSession: [String: Any?]?
  private var activeConfig: [String: Any?]?
  private var healthSink: FlutterEventSink?
  fileprivate var sampleSink: FlutterEventSink?
  private var pendingPermissionResult: FlutterResult?
  private var pendingCurrentLocationResult: FlutterResult?
  private var pendingPermissionTasks = 0
  private let locationManager = CLLocationManager()
  private let motionManager = CMMotionManager()
  private let motionQueue = OperationQueue()
  private var imuChunk = Data()
  private var imuChunkStartedAt = Date()
  private var imuChunkSampleCount = 0
  private var receivedGpsSamples = 0
  private var receivedImuEvents = 0
  private var droppedSamples = 0
  private var gpsStartedAt: Date?
  private var imuStartedAt: Date?
  private var lastGpsSampleAt: Date?
  private var lastImuSampleAt: Date?

  public override init() {
    super.init()
    activeConfig = optionalDictionary(
      UserDefaults.standard.dictionary(forKey: "regattaSensorBridge.config")
    )
    activeSession = optionalDictionary(
      UserDefaults.standard.dictionary(forKey: "regattaSensorBridge.session")
    )
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.allowsBackgroundLocationUpdates = true
    motionQueue.name = "regatta_sensor_bridge.motion"
  }

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
    sampleChannel.setStreamHandler(SampleStreamHandler(plugin: instance))

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
      startTracking(arguments: arguments, result: result)
    case "stopTrackingSession":
      flushImuChunk()
      stopCollectors()
      activeSession = updateSession(state: "stopped", profile: "paused")
      saveState()
      emitHealth(isRunning: false, statusMessage: "Tracking stopped.")
      result(activeSession)
    case "pauseTrackingSession":
      flushImuChunk()
      stopCollectors()
      activeSession = updateSession(state: "paused", profile: "paused")
      activeSession?["pausedAt"] = iso(Date())
      saveState()
      emitHealth(isRunning: false, statusMessage: "Tracking paused.")
      result(activeSession)
    case "resumeTrackingSession":
      activeSession = updateSession(state: "tracking", profile: "raceCruise")
      activeSession?["pausedAt"] = nil
      saveState()
      startCollectors()
      emitHealth(isRunning: true, statusMessage: "Tracking active.")
      result(activeSession)
    case "setTrackingProfile":
      activeSession?["activeProfile"] = arguments["profile"] as? String
      saveState()
      emitHealth(statusMessage: "Tracking profile updated.")
      result(nil)
    case "requestRequiredPermissions":
      requestRequiredPermissions(result: result)
    case "getTrackingHealth":
      result(buildHealth(
        sessionId: arguments["sessionId"] as? String ?? activeSession?["sessionId"] as? String,
        isRunning: activeSession?["state"] as? String == "tracking",
        statusMessage: "Health snapshot requested."
      ))
    case "getCurrentLocation":
      getCurrentLocation(result: result)
    case "getSessionStatus":
      result(activeSession)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func startTracking(arguments: [String: Any?], result: @escaping FlutterResult) {
    let sessionId = arguments["sessionId"] as? String ?? "unknown"
    activeConfig = arguments
    activeSession = [
      "state": "tracking",
      "sessionId": sessionId,
      "startedAt": iso(Date()),
      "lastSampleAt": nil,
      "activeProfile": arguments["initialTrackingProfile"] as? String ?? "prestartPrecision",
      "error": nil,
    ]
    receivedGpsSamples = 0
    receivedImuEvents = 0
    droppedSamples = 0
    gpsStartedAt = nil
    imuStartedAt = nil
    lastGpsSampleAt = nil
    lastImuSampleAt = nil
    imuChunk = Data()
    imuChunkStartedAt = Date()
    imuChunkSampleCount = 0
    saveState()
    startCollectors()
    emitHealth(isRunning: true, statusMessage: "Tracking active.")
    result(activeSession)
  }

  private func startCollectors() {
    locationManager.startUpdatingLocation()
    startMotionCollector()
  }

  private func stopCollectors() {
    locationManager.stopUpdatingLocation()
    motionManager.stopAccelerometerUpdates()
    motionManager.stopGyroUpdates()
    motionManager.stopMagnetometerUpdates()
  }

  private func startMotionCollector() {
    let interval = 1.0 / max(targetImuHz(), 1.0)
    motionManager.accelerometerUpdateInterval = interval
    motionManager.gyroUpdateInterval = interval
    motionManager.magnetometerUpdateInterval = interval

    if motionManager.isAccelerometerAvailable {
      motionManager.startAccelerometerUpdates(to: motionQueue) { [weak self] data, _ in
        guard let data else { return }
        self?.appendImuEvent(sensorType: 1, timestamp: data.timestamp, values: data.acceleration.vector)
      }
    }
    if motionManager.isGyroAvailable {
      motionManager.startGyroUpdates(to: motionQueue) { [weak self] data, _ in
        guard let data else { return }
        self?.appendImuEvent(sensorType: 4, timestamp: data.timestamp, values: data.rotationRate.vector)
      }
    }
    if motionManager.isMagnetometerAvailable {
      motionManager.startMagnetometerUpdates(to: motionQueue) { [weak self] data, _ in
        guard let data else { return }
        self?.appendImuEvent(sensorType: 2, timestamp: data.timestamp, values: data.magneticField.vector)
      }
    }
  }

  private func appendImuEvent(sensorType: Int32, timestamp: TimeInterval, values: [Double]) {
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }
    if imuStartedAt == nil {
      imuStartedAt = Date()
    }
    let now = Date()
    if now.timeIntervalSince(imuChunkStartedAt) >= 1.0 {
      flushImuChunkLocked(now: now)
    }
    appendInt32(sensorType, to: &imuChunk)
    appendInt64(Int64(timestamp * 1_000_000_000), to: &imuChunk)
    appendFloat32(Float(values[safe: 0] ?? 0), to: &imuChunk)
    appendFloat32(Float(values[safe: 1] ?? 0), to: &imuChunk)
    appendFloat32(Float(values[safe: 2] ?? 0), to: &imuChunk)
    appendInt32(3, to: &imuChunk)
    imuChunkSampleCount += 1
    receivedImuEvents += 1
    lastImuSampleAt = now
  }

  private func flushImuChunk() {
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }
    flushImuChunkLocked(now: Date())
  }

  private func flushImuChunkLocked(now: Date) {
    guard imuChunkSampleCount > 0, let sessionId = activeSession?["sessionId"] as? String else {
      imuChunkStartedAt = now
      return
    }
    do {
      let imuDir = sessionDirectory(sessionId).appendingPathComponent("imu", isDirectory: true)
      try FileManager.default.createDirectory(at: imuDir, withIntermediateDirectories: true)
      let chunkId = "imu_\(Int(imuChunkStartedAt.timeIntervalSince1970 * 1000))"
      let fileUrl = imuDir.appendingPathComponent("\(chunkId).bin")
      try imuChunk.write(to: fileUrl, options: .atomic)
      let chunkRef: [String: Any?] = [
        "chunkId": chunkId,
        "startedAt": iso(imuChunkStartedAt),
        "sampleCount": imuChunkSampleCount,
        "storagePath": fileUrl.path,
      ]
      emitSample(gpsPoints: [], imuChunkRefs: [chunkRef])
    } catch {
      droppedSamples += imuChunkSampleCount
    }
    imuChunk = Data()
    imuChunkSampleCount = 0
    imuChunkStartedAt = now
  }

  private func emitSample(gpsPoints: [[String: Any?]], imuChunkRefs: [[String: Any?]]) {
    guard let sessionId = activeSession?["sessionId"] as? String else {
      return
    }
    let payload: [String: Any?] = [
      "sessionId": sessionId,
      "recordedAt": iso(Date()),
      "gpsPoints": gpsPoints,
      "imuChunkRefs": imuChunkRefs,
    ]
    DispatchQueue.main.async {
      self.sampleSink?(payload)
    }
  }

  fileprivate func emitBacklogSamples() {
    guard let sessionId = activeSession?["sessionId"] as? String else {
      return
    }
    let imuDir = sessionDirectory(sessionId).appendingPathComponent("imu", isDirectory: true)
    guard let files = try? FileManager.default.contentsOfDirectory(
      at: imuDir,
      includingPropertiesForKeys: nil
    ) else {
      return
    }
    for fileUrl in files where fileUrl.pathExtension == "bin" {
      let chunkId = fileUrl.deletingPathExtension().lastPathComponent
      let sampleCount = ((try? Data(contentsOf: fileUrl).count) ?? 0) / 28
      let startedAtMillis = Int64(chunkId.replacingOccurrences(of: "imu_", with: "")) ?? 0
      let startedAt = startedAtMillis > 0
        ? Date(timeIntervalSince1970: Double(startedAtMillis) / 1000.0)
        : Date()
      emitSample(
        gpsPoints: [],
        imuChunkRefs: [[
          "chunkId": chunkId,
          "startedAt": iso(startedAt),
          "sampleCount": sampleCount,
          "storagePath": fileUrl.path,
        ]]
      )
    }
  }

  private func appendGps(_ location: CLLocation) {
    guard let sessionId = activeSession?["sessionId"] as? String else {
      return
    }
    if gpsStartedAt == nil {
      gpsStartedAt = Date()
    }
    let payload: [String: Any?] = [
      "timestamp": iso(location.timestamp),
      "longitude": location.coordinate.longitude,
      "latitude": location.coordinate.latitude,
      "accuracyMeters": location.horizontalAccuracy,
      "speedMetersPerSecond": max(location.speed, 0),
    ]
    do {
      let fileUrl = sessionDirectory(sessionId).appendingPathComponent("gps_points.ndjson")
      try FileManager.default.createDirectory(
        at: fileUrl.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      let line = try JSONSerialization.data(withJSONObject: payload.compactMapValues { $0 })
      if !FileManager.default.fileExists(atPath: fileUrl.path) {
        FileManager.default.createFile(atPath: fileUrl.path, contents: nil)
      }
      let handle = try FileHandle(forWritingTo: fileUrl)
      try handle.seekToEnd()
      handle.write(line)
      handle.write(Data("\n".utf8))
      try handle.close()
      receivedGpsSamples += 1
      lastGpsSampleAt = location.timestamp
      activeSession?["lastSampleAt"] = iso(location.timestamp)
      saveState()
      emitSample(gpsPoints: [payload], imuChunkRefs: [])
      emitHealth(isRunning: true, statusMessage: "Tracking active.")
    } catch {
      droppedSamples += 1
    }
  }

  private func getCurrentLocation(result: @escaping FlutterResult) {
    guard pendingCurrentLocationResult == nil else {
      result(FlutterError(
        code: "location_request_in_progress",
        message: "A current location request is already in progress.",
        details: ["isRecoverable": true]
      ))
      return
    }
    guard CLLocationManager.locationServicesEnabled() else {
      result(FlutterError(
        code: "location_unavailable",
        message: "Location services are disabled.",
        details: ["isRecoverable": true]
      ))
      return
    }
    switch locationAuthorizationStatus() {
    case .authorizedAlways, .authorizedWhenInUse:
      if let location = locationManager.location {
        result(gpsPayload(location))
        return
      }
      pendingCurrentLocationResult = result
      locationManager.requestLocation()
    case .notDetermined:
      result(FlutterError(
        code: "location_permission_unknown",
        message: "Location permission has not been requested yet.",
        details: ["isRecoverable": true]
      ))
    case .denied, .restricted:
      result(FlutterError(
        code: "location_permission_denied",
        message: "Location permission is required to read the current position.",
        details: ["isRecoverable": true]
      ))
    @unknown default:
      result(FlutterError(
        code: "location_permission_unknown",
        message: "Location permission state is unknown.",
        details: ["isRecoverable": true]
      ))
    }
  }

  private func gpsPayload(_ location: CLLocation) -> [String: Any?] {
    [
      "timestamp": iso(location.timestamp),
      "longitude": location.coordinate.longitude,
      "latitude": location.coordinate.latitude,
      "accuracyMeters": location.horizontalAccuracy,
      "speedMetersPerSecond": max(location.speed, 0),
    ]
  }

  private func requestRequiredPermissions(result: @escaping FlutterResult) {
    guard pendingPermissionResult == nil else {
      result(FlutterError(
        code: "permission_request_in_progress",
        message: "A runtime permission request is already in progress.",
        details: ["isRecoverable": true]
      ))
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
    let status = locationAuthorizationStatus()
    guard status == .notDetermined else {
      return
    }
    pendingPermissionTasks += 1
    if Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil {
      locationManager.requestAlwaysAuthorization()
    } else {
      locationManager.requestWhenInUseAuthorization()
    }
  }

  private func requestMotionPermissionIfNeeded() {
    guard CMMotionActivityManager.isActivityAvailable() else {
      return
    }
    if #available(iOS 11.0, *) {
      guard CMMotionActivityManager.authorizationStatus() == .notDetermined else {
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
      guard let self else { return }
      guard settings.authorizationStatus == .notDetermined else { return }
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
      "startedAt": iso(Date()),
      "activeProfile": profile,
      "error": nil,
    ]
    session["state"] = state
    session["activeProfile"] = profile
    return session
  }

  private func emitHealth(isRunning: Bool? = nil, statusMessage: String) {
    let payload = buildHealth(
      sessionId: activeSession?["sessionId"] as? String,
      isRunning: isRunning,
      statusMessage: statusMessage
    )
    DispatchQueue.main.async {
      self.healthSink?(payload)
    }
  }

  private func buildHealth(
    sessionId: String?,
    isRunning: Bool? = nil,
    statusMessage: String
  ) -> [String: Any?] {
    return [
      "sessionId": sessionId,
      "recordedAt": iso(Date()),
      "locationPermission": mapLocationPermissionStatus(),
      "motionPermission": mapMotionPermissionStatus(),
      "gpsAvailable": CLLocationManager.locationServicesEnabled(),
      "imuAvailable": motionManager.isAccelerometerAvailable && motionManager.isGyroAvailable,
      "backgroundServiceRunning": isRunning ?? (activeSession?["state"] as? String == "tracking"),
      "droppedSamples": droppedSamples,
      "queueDepth": imuChunkSampleCount,
      "batteryPercent": Double(UIDevice.current.batteryLevel * 100),
      "lastGpsSampleAgeMs": ageMillis(lastGpsSampleAt),
      "lastImuSampleAgeMs": ageMillis(lastImuSampleAt),
      "gpsAccuracyMeters": nil,
      "receivedGpsSamples": receivedGpsSamples,
      "receivedImuSamples": receivedImuEvents,
      "targetGpsHz": targetGpsHz(),
      "targetImuHz": targetImuHz(),
      "averageGpsRateHz": averageRate(count: receivedGpsSamples, startedAt: gpsStartedAt),
      "averageImuRateHz": averageImuRate(),
      "lastGpsSensorTimestamp": lastGpsSampleAt.map(iso),
      "lastImuSensorTimestamp": lastImuSampleAt.map(iso),
      "serviceRestarts": 0,
      "activeTrackingProfile": activeSession?["activeProfile"] as? String,
      "statusMessage": statusMessage,
      "storagePath": sessionId.map { sessionDirectory($0).path },
      "error": nil,
    ]
  }

  private func saveState() {
    UserDefaults.standard.set(activeConfig?.compactMapValues { $0 }, forKey: "regattaSensorBridge.config")
    UserDefaults.standard.set(activeSession?.compactMapValues { $0 }, forKey: "regattaSensorBridge.session")
  }

  private func targetGpsHz() -> Double {
    return activeConfig?["gpsHz"] as? Double ?? 1.0
  }

  private func targetImuHz() -> Double {
    return activeConfig?["imuHz"] as? Double ?? 50.0
  }

  private func averageRate(count: Int, startedAt: Date?) -> Double? {
    guard let startedAt, count > 0 else {
      return nil
    }
    let elapsed = Date().timeIntervalSince(startedAt)
    guard elapsed > 0 else {
      return nil
    }
    return Double(count) / elapsed
  }

  private func averageImuRate() -> Double? {
    guard let rawRate = averageRate(count: receivedImuEvents, startedAt: imuStartedAt) else {
      return nil
    }
    return rawRate / Double(activeImuSensorCount())
  }

  private func activeImuSensorCount() -> Int {
    var count = 0
    if motionManager.isAccelerometerAvailable { count += 1 }
    if motionManager.isGyroAvailable { count += 1 }
    if motionManager.isMagnetometerAvailable { count += 1 }
    return max(1, count)
  }

  private func ageMillis(_ date: Date?) -> Int? {
    guard let date else {
      return nil
    }
    return Int(Date().timeIntervalSince(date) * 1000)
  }

  private func sessionDirectory(_ sessionId: String) -> URL {
    let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
      .appendingPathComponent("regatta_sensor_bridge", isDirectory: true)
      .appendingPathComponent("session_\(sessionId)", isDirectory: true)
    return root
  }

  private func locationAuthorizationStatus() -> CLAuthorizationStatus {
    if #available(iOS 14.0, *) {
      return locationManager.authorizationStatus
    }
    return CLLocationManager.authorizationStatus()
  }

  private func mapLocationPermissionStatus() -> String {
    switch locationAuthorizationStatus() {
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

  private func iso(_ date: Date) -> String {
    ISO8601DateFormatter().string(from: date)
  }
}

extension RegattaSensorBridgePlugin: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    healthSink = events
    events(buildHealth(
      sessionId: activeSession?["sessionId"] as? String,
      statusMessage: "Sensor bridge idle."
    ))
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    healthSink = nil
    return nil
  }
}

extension RegattaSensorBridgePlugin: CLLocationManagerDelegate {
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let result = pendingCurrentLocationResult, let location = locations.last {
      pendingCurrentLocationResult = nil
      result(gpsPayload(location))
    }
    for location in locations {
      appendGps(location)
    }
  }

  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if let result = pendingCurrentLocationResult {
      pendingCurrentLocationResult = nil
      result(FlutterError(
        code: "location_read_failed",
        message: error.localizedDescription,
        details: ["isRecoverable": true]
      ))
    }
    droppedSamples += 1
    emitHealth(statusMessage: "Location update failed.")
  }

  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if #available(iOS 14.0, *) {
      guard manager.authorizationStatus != .notDetermined else {
        return
      }
    }
    completePermissionTask()
  }

  public func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    guard status != .notDetermined else {
      return
    }
    completePermissionTask()
  }
}

private final class SampleStreamHandler: NSObject, FlutterStreamHandler {
  init(plugin: RegattaSensorBridgePlugin) {
    self.plugin = plugin
  }

  private weak var plugin: RegattaSensorBridgePlugin?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    plugin?.sampleSink = events
    plugin?.emitBacklogSamples()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    plugin?.sampleSink = nil
    return nil
  }
}

private extension CMAcceleration {
  var vector: [Double] { [x, y, z] }
}

private extension CMRotationRate {
  var vector: [Double] { [x, y, z] }
}

private extension CMMagneticField {
  var vector: [Double] { [x, y, z] }
}

private extension Array where Element == Double {
  subscript(safe index: Int) -> Double? {
    indices.contains(index) ? self[index] : nil
  }
}

private func appendInt32(_ value: Int32, to data: inout Data) {
  var littleEndian = value.littleEndian
  withUnsafeBytes(of: &littleEndian) { data.append(contentsOf: $0) }
}

private func appendInt64(_ value: Int64, to data: inout Data) {
  var littleEndian = value.littleEndian
  withUnsafeBytes(of: &littleEndian) { data.append(contentsOf: $0) }
}

private func appendFloat32(_ value: Float, to data: inout Data) {
  var littleEndian = value.bitPattern.littleEndian
  withUnsafeBytes(of: &littleEndian) { data.append(contentsOf: $0) }
}

private func optionalDictionary(_ dictionary: [String: Any]?) -> [String: Any?]? {
  guard let dictionary else {
    return nil
  }
  return dictionary.mapValues { Optional($0) }
}
