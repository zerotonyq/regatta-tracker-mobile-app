package com.regatta.regatta_sensor_bridge

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.LocationManager
import android.os.BatteryManager
import android.os.Build
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.time.Instant
import kotlin.math.max

class RegattaTrackingService : Service(), SensorEventListener {
    private companion object {
        const val healthUpdateMinIntervalMillis = 1_000L
    }

    private lateinit var locationClient: FusedLocationProviderClient
    private lateinit var sensorManager: SensorManager
    private lateinit var store: RegattaTrackingStore

    private var activeConfig: SessionConfigPayload? = null
    private var activeProfile: String = "paused"
    private var startedAtIso: String = iso8601()
    private var pausedAtIso: String? = null
    private var lastSampleAtIso: String? = null
    private var lastGpsSensorTimestampIso: String? = null
    private var lastImuSensorTimestampIso: String? = null
    private var serviceRestarts: Int = 0
    private var receivedGpsSamples: Int = 0
    private var receivedImuSamples: Int = 0
    private var droppedSamples: Int = 0
    private var gpsStartMillis: Long = 0
    private var imuStartMillis: Long = 0
    private var lastGpsSampleMillis: Long? = null
    private var lastImuSampleMillis: Long? = null
    private var lastHealthEmitMillis: Long = 0

    private var currentImuChunkStartedAtMillis: Long = 0
    private var currentImuChunkSampleCount: Int = 0
    private var currentImuChunk = ByteArrayOutputStream()

    private val accelerometer by lazy {
        sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    }
    private val gyroscope by lazy {
        sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)
    }
    private val magnetometer by lazy {
        sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)
    }

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            val config = activeConfig ?: return
            for (location in result.locations) {
                val recordedAt = iso8601(location.time)
                val payload = linkedMapOf<String, Any?>(
                    "timestamp" to recordedAt,
                    "longitude" to location.longitude,
                    "latitude" to location.latitude,
                    "accuracyMeters" to location.accuracy.toDouble(),
                    "speedMetersPerSecond" to location.speed.toDouble(),
                )
                try {
                    store.appendGpsPoint(config.sessionId, payload)
                    receivedGpsSamples += 1
                    lastSampleAtIso = recordedAt
                    lastGpsSensorTimestampIso = recordedAt
                    lastGpsSampleMillis = System.currentTimeMillis()
                    if (gpsStartMillis == 0L) {
                        gpsStartMillis = System.currentTimeMillis()
                    }
                    RegattaTrackingSessionManager.emitSample(
                        mapOf(
                            "sessionId" to config.sessionId,
                            "recordedAt" to recordedAt,
                            "gpsPoints" to listOf(payload),
                            "imuChunkRefs" to emptyList<Map<String, Any?>>(),
                        ),
                    )
                    emitHealth("Сбор данных активен.")
                } catch (_: Throwable) {
                    droppedSamples += 1
                    emitHealth("Failed to persist GPS sample.", "gps_persist_failed", true)
                }
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        RegattaTrackingSessionManager.bootstrap(applicationContext)
        locationClient = LocationServices.getFusedLocationProviderClient(this)
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        store = RegattaTrackingStore(applicationContext)
        restorePersistedSessionIfNeeded()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            actionStartTracking -> startSession(intent)
            actionPauseTracking -> pauseSession()
            actionResumeTracking -> resumeSession()
            actionStopTracking -> stopSession()
            actionSetProfile -> setProfile(intent.getStringExtra("profile").orEmpty())
            null -> restorePersistedSessionIfNeeded()
        }
        return START_STICKY
    }

    override fun onDestroy() {
        unregisterCollectors()
        flushImuChunk()
        super.onDestroy()
    }

    override fun onSensorChanged(event: SensorEvent) {
        val config = activeConfig ?: return
        if (activeProfile == "paused") {
            return
        }
        val now = System.currentTimeMillis()
        if (imuStartMillis == 0L) {
            imuStartMillis = now
        }
        if (currentImuChunkStartedAtMillis == 0L) {
            currentImuChunkStartedAtMillis = now
        }
        if (now - currentImuChunkStartedAtMillis >= 1_000) {
            flushImuChunk()
            currentImuChunkStartedAtMillis = now
        }

        val sample = ByteBuffer.allocate(28)
            .order(ByteOrder.LITTLE_ENDIAN)
            .putInt(event.sensor.type)
            .putLong(event.timestamp)
            .putFloat(event.values.getOrElse(0) { 0f })
            .putFloat(event.values.getOrElse(1) { 0f })
            .putFloat(event.values.getOrElse(2) { 0f })
            .putInt(event.accuracy)
            .array()
        currentImuChunk.write(sample)
        currentImuChunkSampleCount += 1
        receivedImuSamples += 1
        lastImuSensorTimestampIso = iso8601()
        lastImuSampleMillis = now
        lastSampleAtIso = iso8601()
        emitHealth("Сбор данных активен.")
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    private fun startSession(intent: Intent) {
        val config = BridgeCodec.run { intent.readSessionConfig() }
        activeConfig = config
        activeProfile = config.initialTrackingProfile
        startedAtIso = iso8601()
        pausedAtIso = null
        lastSampleAtIso = null
        serviceRestarts = 0
        receivedGpsSamples = 0
        receivedImuSamples = 0
        droppedSamples = 0
        gpsStartMillis = 0
        imuStartMillis = 0
        lastGpsSampleMillis = null
        lastImuSampleMillis = null
        resetImuChunk()
        startForegroundInternal(config.sessionId)

        validateTrackingPreconditions(config)?.let { error ->
            val failedStatus = BridgeCodec.createStatusPayload(
                state = "failed",
                sessionId = config.sessionId,
                startedAt = startedAtIso,
                activeProfile = activeProfile,
                error = error,
            )
            RegattaTrackingSessionManager.updateStatus(applicationContext, config, failedStatus)
            emitHealth(error["message"] as? String ?: "Cannot start tracking.", error = error)
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return
        }

        registerCollectors()
        val status = BridgeCodec.createStatusPayload(
            state = "tracking",
            sessionId = config.sessionId,
            startedAt = startedAtIso,
            lastSampleAt = lastSampleAtIso,
            activeProfile = activeProfile,
        )
        RegattaTrackingSessionManager.updateStatus(applicationContext, config, status)
        emitHealth("Foreground tracking active.", force = true)
    }

    private fun pauseSession() {
        val config = activeConfig ?: return
        activeProfile = "paused"
        pausedAtIso = iso8601()
        unregisterCollectors()
        flushImuChunk()
        updateNotification(config.sessionId, "Tracking paused")
        RegattaTrackingSessionManager.updateStatus(
            applicationContext,
            config,
            BridgeCodec.createStatusPayload(
                state = "paused",
                sessionId = config.sessionId,
                startedAt = startedAtIso,
                pausedAt = pausedAtIso,
                lastSampleAt = lastSampleAtIso,
                activeProfile = activeProfile,
            ),
        )
        emitHealth("Tracking paused.", force = true)
    }

    private fun resumeSession() {
        val config = activeConfig ?: return
        validateTrackingPreconditions(config)?.let { error ->
            emitHealth(
                error["message"] as? String ?: "Cannot resume tracking.",
                error = error,
                force = true,
            )
            return
        }
        if (activeProfile == "paused") {
            activeProfile = "raceCruise"
        }
        pausedAtIso = null
        registerCollectors()
        updateNotification(config.sessionId, "Tracking active")
        RegattaTrackingSessionManager.updateStatus(
            applicationContext,
            config,
            BridgeCodec.createStatusPayload(
                state = "tracking",
                sessionId = config.sessionId,
                startedAt = startedAtIso,
                pausedAt = null,
                lastSampleAt = lastSampleAtIso,
                activeProfile = activeProfile,
            ),
        )
        emitHealth("Tracking resumed.", force = true)
    }

    private fun stopSession() {
        val config = activeConfig ?: return
        unregisterCollectors()
        flushImuChunk()
        val status = BridgeCodec.createStatusPayload(
            state = "stopped",
            sessionId = config.sessionId,
            startedAt = startedAtIso,
            pausedAt = pausedAtIso,
            lastSampleAt = lastSampleAtIso,
            activeProfile = "paused",
        )
        RegattaTrackingSessionManager.updateStatus(applicationContext, config, status)
        emitHealth("Tracking stopped.", force = true)
        stopForeground(STOP_FOREGROUND_REMOVE)
        RegattaTrackingSessionManager.clearSession(applicationContext)
        stopSelf()
    }

    private fun setProfile(profile: String) {
        val config = activeConfig ?: return
        activeProfile = profile.ifEmpty { activeProfile }
        if (activeProfile == "paused") {
            unregisterLocation()
            flushImuChunk()
        } else if (isLocationPermissionGranted()) {
            restartLocationUpdates()
        }
        RegattaTrackingSessionManager.updateStatus(
            applicationContext,
            config,
            BridgeCodec.createStatusPayload(
                state = if (activeProfile == "paused") "paused" else "tracking",
                sessionId = config.sessionId,
                startedAt = startedAtIso,
                pausedAt = if (activeProfile == "paused") iso8601() else null,
                lastSampleAt = lastSampleAtIso,
                activeProfile = activeProfile,
            ),
        )
        emitHealth("Tracking profile switched to $activeProfile.", force = true)
    }

    private fun registerCollectors() {
        restartLocationUpdates()
        registerImuSensors()
    }

    private fun unregisterCollectors() {
        unregisterLocation()
        sensorManager.unregisterListener(this)
    }

    private fun restartLocationUpdates() {
        unregisterLocation()
        val config = activeConfig ?: return
        if (activeProfile == "paused") {
            return
        }
        if (!isLocationPermissionGranted()) {
            emitHealth("Location permission missing.", "location_permission_missing", true, force = true)
            return
        }
        val policy = TrackingProfilePolicy.gpsPolicy(activeProfile)
        val request = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            max(1_000L, policy.intervalMillis),
        )
            .setMinUpdateDistanceMeters(policy.minDistanceMeters)
            .setWaitForAccurateLocation(true)
            .setMinUpdateIntervalMillis(max(1_000L, policy.intervalMillis))
            .build()
        locationClient.requestLocationUpdates(
            request,
            locationCallback,
            Looper.getMainLooper(),
        )
        updateNotification(config.sessionId, "Tracking active")
    }

    private fun unregisterLocation() {
        locationClient.removeLocationUpdates(locationCallback)
    }

    private fun registerImuSensors() {
        val config = activeConfig ?: return
        val samplingPeriodUs = max(1, (1_000_000.0 / max(1.0, config.imuHz)).toInt())
        accelerometer?.let { sensorManager.registerListener(this, it, samplingPeriodUs) }
        gyroscope?.let { sensorManager.registerListener(this, it, samplingPeriodUs) }
        magnetometer?.let { sensorManager.registerListener(this, it, samplingPeriodUs) }
    }

    private fun flushImuChunk() {
        val config = activeConfig ?: return
        if (currentImuChunkSampleCount == 0 || currentImuChunkStartedAtMillis == 0L) {
            return
        }
        try {
            val chunkRef = store.flushImuChunk(
                sessionId = config.sessionId,
                chunkStartedAtMillis = currentImuChunkStartedAtMillis,
                sampleCount = currentImuChunkSampleCount,
                bytes = currentImuChunk,
            )
            RegattaTrackingSessionManager.emitSample(
                mapOf(
                    "sessionId" to config.sessionId,
                    "recordedAt" to iso8601(),
                    "gpsPoints" to emptyList<Map<String, Any?>>(),
                    "imuChunkRefs" to listOf(chunkRef),
                ),
            )
            emitHealth("IMU chunk flushed.")
        } catch (_: Throwable) {
            droppedSamples += currentImuChunkSampleCount
            emitHealth("Failed to flush IMU chunk.", "imu_flush_failed", true, force = true)
        } finally {
            resetImuChunk()
        }
    }

    private fun resetImuChunk() {
        currentImuChunk = ByteArrayOutputStream()
        currentImuChunkSampleCount = 0
        currentImuChunkStartedAtMillis = 0
    }

    private fun validateTrackingPreconditions(config: SessionConfigPayload): Map<String, Any>? {
        if (!isLocationPermissionGranted()) {
            return BridgeCodec.createErrorPayload(
                code = "location_permission_missing",
                message = "ACCESS_FINE_LOCATION is required for Android tracking.",
                isRecoverable = true,
            )
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_BACKGROUND_LOCATION,
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return BridgeCodec.createErrorPayload(
                code = "background_location_missing",
                message = "ACCESS_BACKGROUND_LOCATION is required for background regatta tracking.",
                isRecoverable = true,
            )
        }
        if (!isGpsEnabled()) {
            return BridgeCodec.createErrorPayload(
                code = "gps_disabled",
                message = "Device GPS provider is disabled.",
                isRecoverable = true,
            )
        }
        if (config.backgroundMode == "disabled") {
            return BridgeCodec.createErrorPayload(
                code = "background_mode_disabled",
                message = "Android tracking step requires foreground service background mode.",
                isRecoverable = false,
            )
        }
        return null
    }

    private fun emitHealth(
        message: String,
        errorCode: String? = null,
        isRecoverable: Boolean = false,
        force: Boolean = false,
        error: Map<String, Any>? = errorCode?.let {
            BridgeCodec.createErrorPayload(it, message, isRecoverable)
        },
    ) {
        val now = System.currentTimeMillis()
        if (!force && now - lastHealthEmitMillis < healthUpdateMinIntervalMillis) {
            return
        }
        lastHealthEmitMillis = now

        val sessionId = activeConfig?.sessionId
        val healthPayload = linkedMapOf<String, Any?>(
            "sessionId" to sessionId,
            "recordedAt" to iso8601(),
            "locationPermission" to locationPermissionState(),
            "motionPermission" to motionPermissionState(),
            "gpsAvailable" to isGpsEnabled(),
            "imuAvailable" to (accelerometer != null && gyroscope != null),
            "backgroundServiceRunning" to (activeConfig != null && activeProfile != "paused"),
            "droppedSamples" to droppedSamples,
            "queueDepth" to currentImuChunkSampleCount,
            "batteryPercent" to currentBatteryPercent(),
            "lastGpsSampleAgeMs" to lastGpsSampleMillis?.let { System.currentTimeMillis() - it },
            "lastImuSampleAgeMs" to lastImuSampleMillis?.let { System.currentTimeMillis() - it },
            "gpsAccuracyMeters" to null,
            "receivedGpsSamples" to receivedGpsSamples,
            "receivedImuSamples" to receivedImuSamples,
            "targetGpsHz" to activeConfig?.gpsHz,
            "targetImuHz" to activeConfig?.imuHz,
            "averageGpsRateHz" to averageRateHz(receivedGpsSamples, gpsStartMillis),
            "averageImuRateHz" to averageImuRateHz(),
            "lastGpsSensorTimestamp" to lastGpsSensorTimestampIso,
            "lastImuSensorTimestamp" to lastImuSensorTimestampIso,
            "serviceRestarts" to serviceRestarts,
            "activeTrackingProfile" to activeProfile,
            "statusMessage" to message,
            "storagePath" to (sessionId?.let { store.sessionPath(it) } ?: store.rootPath()),
            "error" to error,
        )
        sessionId?.let { store.appendHealth(it, healthPayload) }
        RegattaTrackingSessionManager.updateHealth(applicationContext, healthPayload)
    }

    private fun restorePersistedSessionIfNeeded() {
        val config = RegattaTrackingSessionManager.activeConfig() ?: return
        if (activeConfig != null) {
            return
        }
        activeConfig = config
        activeProfile =
            (RegattaTrackingSessionManager.activeStatus(config.sessionId)?.get("activeProfile") as? String)
                ?: config.initialTrackingProfile
        startedAtIso =
            (RegattaTrackingSessionManager.activeStatus(config.sessionId)?.get("startedAt") as? String)
                ?: iso8601()
        pausedAtIso =
            RegattaTrackingSessionManager.activeStatus(config.sessionId)?.get("pausedAt") as? String
        lastSampleAtIso =
            RegattaTrackingSessionManager.activeStatus(config.sessionId)?.get("lastSampleAt") as? String
        serviceRestarts =
            ((RegattaTrackingSessionManager.latestHealth(config.sessionId)["serviceRestarts"] as? Int)
                ?: 0) + 1
        startForegroundInternal(config.sessionId)
        if (activeProfile != "paused") {
            registerCollectors()
        }
        emitHealth("Foreground service restored after restart.", force = true)
    }

    private fun startForegroundInternal(sessionId: String) {
        createNotificationChannelIfNeeded()
        val notification = buildNotification(
            sessionId = sessionId,
            contentText = if (activeProfile == "paused") "Tracking paused" else "Tracking active",
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                7017,
                notification,
                ServiceInfoCompat.foregroundServiceTypeLocation(),
            )
        } else {
            startForeground(7017, notification)
        }
    }

    private fun updateNotification(sessionId: String, contentText: String) {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(7017, buildNotification(sessionId, contentText))
    }

    private fun buildNotification(sessionId: String, contentText: String): Notification {
        return NotificationCompat.Builder(this, "regatta_tracking")
            .setContentTitle("Regatta tracking")
            .setContentText("Session $sessionId: $contentText")
            .setSmallIcon(applicationInfo.icon)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()
    }

    private fun createNotificationChannelIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            "regatta_tracking",
            "Regatta tracking",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Foreground sensor collection for regatta tracking."
        }
        manager.createNotificationChannel(channel)
    }

    private fun currentBatteryPercent(): Double? {
        val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = batteryIntent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        if (level < 0 || scale <= 0) {
            return null
        }
        return (level * 100.0) / scale
    }

    private fun averageRateHz(sampleCount: Int, startedAtMillis: Long): Double? {
        if (sampleCount <= 0 || startedAtMillis <= 0L) {
            return null
        }
        val elapsedSeconds = (System.currentTimeMillis() - startedAtMillis) / 1000.0
        if (elapsedSeconds <= 0.0) {
            return null
        }
        return sampleCount / elapsedSeconds
    }

    private fun averageImuRateHz(): Double? {
        val rawRate = averageRateHz(receivedImuSamples, imuStartMillis) ?: return null
        return rawRate / activeImuSensorCount()
    }

    private fun activeImuSensorCount(): Int {
        var count = 0
        if (accelerometer != null) count += 1
        if (gyroscope != null) count += 1
        if (magnetometer != null) count += 1
        return max(1, count)
    }

    private fun isGpsEnabled(): Boolean {
        val manager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        return manager.isProviderEnabled(LocationManager.GPS_PROVIDER)
    }

    private fun isLocationPermissionGranted(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun locationPermissionState(): String {
        if (isLocationPermissionGranted()) {
            return "granted"
        }
        return "denied"
    }

    private fun motionPermissionState(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return "granted"
        }
        return if (
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACTIVITY_RECOGNITION,
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            "granted"
        } else {
            "denied"
        }
    }
}

private object ServiceInfoCompat {
    fun foregroundServiceTypeLocation(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
        } else {
            0
        }
    }
}

internal fun defaultHealthPayload(
    sessionId: String? = null,
    serviceRestarts: Int = 0,
    storagePath: String? = null,
    activeTrackingProfile: String? = null,
    statusMessage: String = "Sensor bridge idle.",
): Map<String, Any?> {
    return linkedMapOf(
        "sessionId" to sessionId,
        "recordedAt" to iso8601(),
        "locationPermission" to "unknown",
        "motionPermission" to "unknown",
        "gpsAvailable" to false,
        "imuAvailable" to false,
        "backgroundServiceRunning" to false,
        "droppedSamples" to 0,
        "queueDepth" to 0,
        "batteryPercent" to null,
        "lastGpsSampleAgeMs" to null,
        "lastImuSampleAgeMs" to null,
        "gpsAccuracyMeters" to null,
        "receivedGpsSamples" to 0,
        "receivedImuSamples" to 0,
        "targetGpsHz" to null,
        "targetImuHz" to null,
        "averageGpsRateHz" to null,
        "averageImuRateHz" to null,
        "lastGpsSensorTimestamp" to null,
        "lastImuSensorTimestamp" to null,
        "serviceRestarts" to serviceRestarts,
        "activeTrackingProfile" to activeTrackingProfile,
        "statusMessage" to statusMessage,
        "storagePath" to storagePath,
        "error" to null,
    )
}

internal fun iso8601(epochMillis: Long = System.currentTimeMillis()): String {
    return Instant.ofEpochMilli(epochMillis).toString()
}
