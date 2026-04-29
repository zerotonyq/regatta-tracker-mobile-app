package com.regatta.regatta_sensor_bridge

import android.content.Intent

internal const val actionStartTracking = "com.regatta.regatta_sensor_bridge.START_TRACKING"
internal const val actionPauseTracking = "com.regatta.regatta_sensor_bridge.PAUSE_TRACKING"
internal const val actionResumeTracking = "com.regatta.regatta_sensor_bridge.RESUME_TRACKING"
internal const val actionStopTracking = "com.regatta.regatta_sensor_bridge.STOP_TRACKING"
internal const val actionSetProfile = "com.regatta.regatta_sensor_bridge.SET_PROFILE"

internal data class SessionConfigPayload(
    val sessionId: String,
    val raceId: Int,
    val role: String,
    val gpsHz: Double,
    val imuHz: Double,
    val desiredAccuracy: String,
    val backgroundMode: String,
    val bufferingPolicy: String,
    val initialTrackingProfile: String,
) {
    fun asMap(): Map<String, Any> {
        return mapOf(
            "sessionId" to sessionId,
            "raceId" to raceId,
            "role" to role,
            "gpsHz" to gpsHz,
            "imuHz" to imuHz,
            "desiredAccuracy" to desiredAccuracy,
            "backgroundMode" to backgroundMode,
            "bufferingPolicy" to bufferingPolicy,
            "initialTrackingProfile" to initialTrackingProfile,
        )
    }
}

internal object BridgeCodec {
    fun parseSessionConfig(arguments: Map<*, *>): SessionConfigPayload {
        return SessionConfigPayload(
            sessionId = arguments.stringValue("sessionId"),
            raceId = arguments.intValue("raceId"),
            role = arguments.stringValue("role"),
            gpsHz = arguments.doubleValue("gpsHz"),
            imuHz = arguments.doubleValue("imuHz"),
            desiredAccuracy = arguments.stringValue("desiredAccuracy"),
            backgroundMode = arguments.stringValue("backgroundMode"),
            bufferingPolicy = arguments.stringValue("bufferingPolicy"),
            initialTrackingProfile = arguments.stringValue("initialTrackingProfile"),
        )
    }

    fun createStatusPayload(
        state: String,
        sessionId: String,
        startedAt: String,
        pausedAt: String? = null,
        lastSampleAt: String? = null,
        activeProfile: String? = null,
        error: Map<String, Any?>? = null,
    ): Map<String, Any?> {
        return linkedMapOf<String, Any?>(
            "state" to state,
            "sessionId" to sessionId,
            "startedAt" to startedAt,
            "pausedAt" to pausedAt,
            "lastSampleAt" to lastSampleAt,
            "activeProfile" to activeProfile,
            "error" to error,
        )
    }

    fun createErrorPayload(
        code: String,
        message: String,
        isRecoverable: Boolean,
    ): Map<String, Any> {
        return mapOf(
            "code" to code,
            "message" to message,
            "isRecoverable" to isRecoverable,
        )
    }

    fun Intent.putSessionConfig(config: SessionConfigPayload): Intent {
        putExtra("sessionId", config.sessionId)
        putExtra("raceId", config.raceId)
        putExtra("role", config.role)
        putExtra("gpsHz", config.gpsHz)
        putExtra("imuHz", config.imuHz)
        putExtra("desiredAccuracy", config.desiredAccuracy)
        putExtra("backgroundMode", config.backgroundMode)
        putExtra("bufferingPolicy", config.bufferingPolicy)
        putExtra("initialTrackingProfile", config.initialTrackingProfile)
        return this
    }

    fun Intent.readSessionConfig(): SessionConfigPayload {
        return SessionConfigPayload(
            sessionId = getStringExtra("sessionId").orEmpty(),
            raceId = getIntExtra("raceId", 0),
            role = getStringExtra("role").orEmpty(),
            gpsHz = getDoubleExtra("gpsHz", 1.0),
            imuHz = getDoubleExtra("imuHz", 50.0),
            desiredAccuracy = getStringExtra("desiredAccuracy").orEmpty(),
            backgroundMode = getStringExtra("backgroundMode").orEmpty(),
            bufferingPolicy = getStringExtra("bufferingPolicy").orEmpty(),
            initialTrackingProfile = getStringExtra("initialTrackingProfile").orEmpty(),
        )
    }
}

private fun Map<*, *>.doubleValue(key: String): Double {
    val value = this[key]
    return when (value) {
        is Number -> value.toDouble()
        else -> error("Missing double value for $key")
    }
}

private fun Map<*, *>.intValue(key: String): Int {
    val value = this[key]
    return when (value) {
        is Number -> value.toInt()
        else -> error("Missing int value for $key")
    }
}

private fun Map<*, *>.stringValue(key: String): String {
    return this[key] as? String ?: error("Missing string value for $key")
}
