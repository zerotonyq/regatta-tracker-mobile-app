package com.regatta.regatta_sensor_bridge

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorManager
import android.location.LocationManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class RegattaSensorBridgePlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {
    private lateinit var applicationContext: Context
    private lateinit var methodChannel: MethodChannel
    private lateinit var sampleChannel: EventChannel
    private lateinit var healthChannel: EventChannel
    private var sampleStreamHandler: SessionStreamHandler? = null
    private var healthStreamHandler: SessionStreamHandler? = null

    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        RegattaTrackingSessionManager.bootstrap(applicationContext)

        methodChannel = MethodChannel(binding.binaryMessenger, "regatta_sensor_bridge/methods")
        methodChannel.setMethodCallHandler(this)

        sampleChannel = EventChannel(binding.binaryMessenger, "regatta_sensor_bridge/samples")
        sampleStreamHandler =
            SessionStreamHandler(
                latestValue = { sessionId -> null },
                subscribe = { sink, sessionId ->
                    sessionId?.let { id ->
                        val chunkRefs = RegattaTrackingStore(applicationContext).listImuChunkRefs(id)
                        for (chunkRef in chunkRefs) {
                            sink.success(
                                mapOf(
                                    "sessionId" to id,
                                    "recordedAt" to iso8601(),
                                    "gpsPoints" to emptyList<Map<String, Any?>>(),
                                    "imuChunkRefs" to listOf(chunkRef),
                                ),
                            )
                        }
                    }
                    RegattaTrackingSessionManager.registerSampleListener { sample ->
                        if (sessionId == null || sample["sessionId"] == sessionId) {
                            sink.success(sample)
                        }
                    }
                },
            )
        sampleChannel.setStreamHandler(sampleStreamHandler)

        healthChannel = EventChannel(binding.binaryMessenger, "regatta_sensor_bridge/health")
        healthStreamHandler =
            SessionStreamHandler(
                latestValue = { sessionId -> RegattaTrackingSessionManager.latestHealth(sessionId) },
                subscribe = { sink, sessionId ->
                    RegattaTrackingSessionManager.registerHealthListener { health ->
                        if (sessionId == null || health["sessionId"] == sessionId) {
                            sink.success(health)
                        }
                    }
                },
            )
        healthChannel.setStreamHandler(healthStreamHandler)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any?>()
        try {
            when (call.method) {
                "startTrackingSession" -> {
                    val config = BridgeCodec.parseSessionConfig(args)
                    val fallbackStatus =
                        BridgeCodec.createStatusPayload(
                            state = "preparing",
                            sessionId = config.sessionId,
                            startedAt = iso8601(),
                            activeProfile = config.initialTrackingProfile,
                        )
                    RegattaTrackingSessionManager.updateStatus(
                        applicationContext,
                        config,
                        fallbackStatus,
                    )
                    startTrackingService(
                        Intent(applicationContext, RegattaTrackingService::class.java)
                            .setAction(actionStartTracking)
                            .also { intent ->
                                BridgeCodec.run { intent.putSessionConfig(config) }
                            },
                    )
                    result.success(fallbackStatus)
                }
                "stopTrackingSession" -> {
                    val sessionId = args["sessionId"] as? String ?: return result.notImplemented()
                    val fallbackStatus =
                        BridgeCodec.createStatusPayload(
                            state = "stopped",
                            sessionId = sessionId,
                            startedAt = iso8601(),
                            activeProfile = "paused",
                        )
                    startTrackingService(
                        Intent(applicationContext, RegattaTrackingService::class.java)
                            .setAction(actionStopTracking)
                            .putExtra("sessionId", sessionId),
                    )
                    result.success(fallbackStatus)
                }
                "pauseTrackingSession" -> {
                    val sessionId = args["sessionId"] as? String ?: return result.notImplemented()
                    val fallbackStatus =
                        BridgeCodec.createStatusPayload(
                            state = "paused",
                            sessionId = sessionId,
                            startedAt = iso8601(),
                            pausedAt = iso8601(),
                            activeProfile = "paused",
                        )
                    startTrackingService(
                        Intent(applicationContext, RegattaTrackingService::class.java)
                            .setAction(actionPauseTracking)
                            .putExtra("sessionId", sessionId),
                    )
                    result.success(fallbackStatus)
                }
                "resumeTrackingSession" -> {
                    val sessionId = args["sessionId"] as? String ?: return result.notImplemented()
                    val fallbackStatus =
                        BridgeCodec.createStatusPayload(
                            state = "tracking",
                            sessionId = sessionId,
                            startedAt = iso8601(),
                            activeProfile = "raceCruise",
                        )
                    startTrackingService(
                        Intent(applicationContext, RegattaTrackingService::class.java)
                            .setAction(actionResumeTracking)
                            .putExtra("sessionId", sessionId),
                    )
                    result.success(fallbackStatus)
                }
                "setTrackingProfile" -> {
                    val sessionId = args["sessionId"] as? String ?: return result.notImplemented()
                    val profile = args["profile"] as? String ?: return result.notImplemented()
                    startTrackingService(
                        Intent(applicationContext, RegattaTrackingService::class.java)
                            .setAction(actionSetProfile)
                            .putExtra("sessionId", sessionId)
                            .putExtra("profile", profile),
                    )
                    result.success(null)
                }
                "requestRequiredPermissions" -> requestRequiredPermissions(result)
                "getTrackingHealth" -> {
                    val sessionId = args["sessionId"] as? String
                    val health = buildCurrentHealthPayload(
                        statusMessage = "Health snapshot requested.",
                        sessionIdOverride = sessionId,
                    )
                    RegattaTrackingSessionManager.updateHealth(applicationContext, health)
                    result.success(health)
                }
                "getSessionStatus" -> {
                    val sessionId = args["sessionId"] as? String
                    result.success(RegattaTrackingSessionManager.activeStatus(sessionId))
                }
                else -> result.notImplemented()
            }
        } catch (error: IllegalStateException) {
            result.error(
                "tracking_state_error",
                error.message,
                mapOf("isRecoverable" to false),
            )
        } catch (error: SecurityException) {
            result.error(
                "security_exception",
                error.message,
                mapOf("isRecoverable" to true),
            )
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        sampleStreamHandler?.close()
        healthStreamHandler?.close()
        sampleChannel.setStreamHandler(null)
        healthChannel.setStreamHandler(null)
        sampleStreamHandler = null
        healthStreamHandler = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        clearActivityBinding()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        clearActivityBinding()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != requestCodeRequiredPermissionsForeground &&
            requestCode != requestCodeRequiredPermissionsBackground
        ) {
            return false
        }

        continuePermissionRequest()
        return true
    }

    private fun clearActivityBinding() {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activityBinding = null
        activity = null
    }

    private fun requestRequiredPermissions(result: MethodChannel.Result) {
        if (pendingPermissionResult != null) {
            result.error(
                "permission_request_in_progress",
                "A runtime permission request is already in progress.",
                mapOf("isRecoverable" to true),
            )
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            val health = buildCurrentHealthPayload("Runtime permissions already granted.")
            RegattaTrackingSessionManager.updateHealth(applicationContext, health)
            result.success(health)
            return
        }

        if (activity == null) {
            result.error(
                "activity_unavailable",
                "Runtime permissions require an attached foreground activity.",
                mapOf("isRecoverable" to true),
            )
            return
        }

        pendingPermissionResult = result
        continuePermissionRequest()
    }

    private fun continuePermissionRequest() {
        val activeActivity = activity
        val pendingResult = pendingPermissionResult
        if (activeActivity == null || pendingResult == null) {
            finishPermissionRequestWithError(
                code = "activity_unavailable",
                message = "Runtime permissions require an attached foreground activity.",
            )
            return
        }

        val foregroundPermissions = mutableListOf<String>()
        if (!hasPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
            foregroundPermissions += Manifest.permission.ACCESS_FINE_LOCATION
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            !hasPermission(Manifest.permission.ACTIVITY_RECOGNITION)
        ) {
            foregroundPermissions += Manifest.permission.ACTIVITY_RECOGNITION
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            !hasPermission(Manifest.permission.POST_NOTIFICATIONS)
        ) {
            foregroundPermissions += Manifest.permission.POST_NOTIFICATIONS
        }

        if (foregroundPermissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                activeActivity,
                foregroundPermissions.toTypedArray(),
                requestCodeRequiredPermissionsForeground,
            )
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            hasPermission(Manifest.permission.ACCESS_FINE_LOCATION) &&
            !hasPermission(Manifest.permission.ACCESS_BACKGROUND_LOCATION)
        ) {
            ActivityCompat.requestPermissions(
                activeActivity,
                arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
                requestCodeRequiredPermissionsBackground,
            )
            return
        }

        finishPermissionRequestSuccessfully()
    }

    private fun finishPermissionRequestSuccessfully() {
        val result = pendingPermissionResult ?: return
        pendingPermissionResult = null
        val health = buildCurrentHealthPayload("Runtime permissions updated.")
        RegattaTrackingSessionManager.updateHealth(applicationContext, health)
        result.success(health)
    }

    private fun finishPermissionRequestWithError(code: String, message: String) {
        val result = pendingPermissionResult ?: return
        pendingPermissionResult = null
        result.error(code, message, mapOf("isRecoverable" to true))
    }

    private fun hasPermission(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(
            applicationContext,
            permission,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun buildCurrentHealthPayload(
        statusMessage: String,
        sessionIdOverride: String? = null,
    ): Map<String, Any?> {
        val activeConfig = RegattaTrackingSessionManager.activeConfig()
        val sessionId = sessionIdOverride ?: activeConfig?.sessionId
        val latestHealth = RegattaTrackingSessionManager.latestHealth(sessionId)
        val status = RegattaTrackingSessionManager.activeStatus(sessionId)
        val sensorManager =
            applicationContext.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        val gyroscope = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)

        return LinkedHashMap<String, Any?>().apply {
            putAll(latestHealth)
            this["sessionId"] = sessionId
            this["recordedAt"] = iso8601()
            this["locationPermission"] = locationPermissionState()
            this["motionPermission"] = motionPermissionState()
            this["gpsAvailable"] = isGpsEnabled()
            this["imuAvailable"] = accelerometer != null && gyroscope != null
            this["backgroundServiceRunning"] = status?.get("state") == "tracking"
            this["activeTrackingProfile"] =
                status?.get("activeProfile") ?: latestHealth["activeTrackingProfile"]
            this["statusMessage"] = statusMessage
            this["error"] = null
        }
    }

    private fun locationPermissionState(): String {
        if (!hasPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
            return "denied"
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            !hasPermission(Manifest.permission.ACCESS_BACKGROUND_LOCATION)
        ) {
            return "denied"
        }
        return "granted"
    }

    private fun motionPermissionState(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return "granted"
        }
        return if (hasPermission(Manifest.permission.ACTIVITY_RECOGNITION)) {
            "granted"
        } else {
            "denied"
        }
    }

    private fun isGpsEnabled(): Boolean {
        val manager = applicationContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        return manager.isProviderEnabled(LocationManager.GPS_PROVIDER)
    }

    private fun startTrackingService(intent: Intent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            applicationContext.startForegroundService(intent)
        } else {
            applicationContext.startService(intent)
        }
    }
}

private class SessionStreamHandler(
    private val latestValue: (String?) -> Map<String, Any?>?,
    private val subscribe: (EventChannel.EventSink, String?) -> (() -> Unit),
) : EventChannel.StreamHandler {
    private var unsubscribe: (() -> Unit)? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        unsubscribe?.invoke()
        val sessionId = (arguments as? Map<*, *>)?.get("sessionId") as? String
        latestValue(sessionId)?.let(events::success)
        unsubscribe = subscribe(events, sessionId)
    }

    override fun onCancel(arguments: Any?) {
        unsubscribe?.invoke()
        unsubscribe = null
    }

    fun close() {
        unsubscribe?.invoke()
        unsubscribe = null
    }
}

private const val requestCodeRequiredPermissionsForeground = 40117
private const val requestCodeRequiredPermissionsBackground = 40118
