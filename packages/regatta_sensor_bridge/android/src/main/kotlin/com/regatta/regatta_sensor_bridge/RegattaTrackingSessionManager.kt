package com.regatta.regatta_sensor_bridge

import android.content.Context
import android.content.SharedPreferences

internal object RegattaTrackingSessionManager {
    private const val prefsName = "regatta_sensor_bridge_state"

    private val lock = Any()
    private var bootstrapped = false
    private var activeConfig: SessionConfigPayload? = null
    private var activeStatus: Map<String, Any?>? = null
    private var latestHealth: Map<String, Any?> = defaultHealthPayload()
    private val healthListeners = linkedSetOf<(Map<String, Any?>) -> Unit>()
    private val sampleListeners = linkedSetOf<(Map<String, Any?>) -> Unit>()

    fun bootstrap(context: Context) {
        synchronized(lock) {
            if (bootstrapped) {
                return
            }
            val prefs = prefs(context)
            val sessionId = prefs.getString("sessionId", null)
            if (sessionId != null) {
                activeConfig = SessionConfigPayload(
                    sessionId = sessionId,
                    raceId = prefs.getInt("raceId", 0),
                    role = prefs.getString("role", "participant").orEmpty(),
                    gpsHz = prefs.getFloat("gpsHz", 1f).toDouble(),
                    imuHz = prefs.getFloat("imuHz", 50f).toDouble(),
                    desiredAccuracy = prefs.getString("desiredAccuracy", "high").orEmpty(),
                    backgroundMode = prefs.getString("backgroundMode", "foregroundService").orEmpty(),
                    bufferingPolicy = prefs.getString("bufferingPolicy", "persistNativeBuffer").orEmpty(),
                    initialTrackingProfile = prefs.getString("initialTrackingProfile", "prestartPrecision").orEmpty(),
                )
                activeStatus = BridgeCodec.createStatusPayload(
                    state = prefs.getString("state", "paused").orEmpty(),
                    sessionId = sessionId,
                    startedAt = prefs.getString("startedAt", iso8601()).orEmpty(),
                    pausedAt = prefs.getString("pausedAt", null),
                    lastSampleAt = prefs.getString("lastSampleAt", null),
                    activeProfile = prefs.getString("activeProfile", null),
                    error = null,
                )
                latestHealth = defaultHealthPayload(
                    sessionId = sessionId,
                    serviceRestarts = prefs.getInt("serviceRestarts", 0),
                    storagePath = prefs.getString("storagePath", null),
                    activeTrackingProfile = prefs.getString("activeProfile", null),
                    statusMessage = "Recovered tracking state from persistence.",
                )
            }
            bootstrapped = true
        }
    }

    fun activeConfig(): SessionConfigPayload? = synchronized(lock) { activeConfig }

    fun activeStatus(sessionId: String?): Map<String, Any?>? = synchronized(lock) {
        val current = activeStatus ?: return null
        if (sessionId == null || current["sessionId"] == sessionId) {
            LinkedHashMap(current)
        } else {
            null
        }
    }

    fun latestHealth(sessionId: String?): Map<String, Any?> = synchronized(lock) {
        LinkedHashMap(latestHealth).apply {
            if (sessionId != null) {
                this["sessionId"] = sessionId
            }
        }
    }

    fun updateStatus(context: Context, config: SessionConfigPayload, status: Map<String, Any?>) {
        synchronized(lock) {
            activeConfig = config
            activeStatus = LinkedHashMap(status)
            persistLocked(context)
        }
    }

    fun updateHealth(context: Context, health: Map<String, Any?>) {
        val listeners = synchronized(lock) {
            latestHealth = LinkedHashMap(health)
            persistLocked(context)
            healthListeners.toList()
        }
        listeners.forEach { it(LinkedHashMap(health)) }
    }

    fun emitSample(sample: Map<String, Any?>) {
        val listeners = synchronized(lock) { sampleListeners.toList() }
        listeners.forEach { it(LinkedHashMap(sample)) }
    }

    fun registerHealthListener(listener: (Map<String, Any?>) -> Unit): () -> Unit {
        synchronized(lock) {
            healthListeners += listener
        }
        return {
            synchronized(lock) {
                healthListeners -= listener
            }
        }
    }

    fun registerSampleListener(listener: (Map<String, Any?>) -> Unit): () -> Unit {
        synchronized(lock) {
            sampleListeners += listener
        }
        return {
            synchronized(lock) {
                sampleListeners -= listener
            }
        }
    }

    fun clearSession(context: Context) {
        synchronized(lock) {
            activeConfig = null
            activeStatus = null
            latestHealth = defaultHealthPayload(statusMessage = "Tracking service stopped.")
            prefs(context).edit().clear().apply()
        }
    }

    private fun persistLocked(context: Context) {
        val config = activeConfig ?: return
        val status = activeStatus ?: return
        prefs(context).edit()
            .putString("sessionId", config.sessionId)
            .putInt("raceId", config.raceId)
            .putString("role", config.role)
            .putFloat("gpsHz", config.gpsHz.toFloat())
            .putFloat("imuHz", config.imuHz.toFloat())
            .putString("desiredAccuracy", config.desiredAccuracy)
            .putString("backgroundMode", config.backgroundMode)
            .putString("bufferingPolicy", config.bufferingPolicy)
            .putString("initialTrackingProfile", config.initialTrackingProfile)
            .putString("state", status["state"] as? String)
            .putString("startedAt", status["startedAt"] as? String)
            .putString("pausedAt", status["pausedAt"] as? String)
            .putString("lastSampleAt", status["lastSampleAt"] as? String)
            .putString("activeProfile", status["activeProfile"] as? String)
            .putInt("serviceRestarts", (latestHealth["serviceRestarts"] as? Int) ?: 0)
            .putString("storagePath", latestHealth["storagePath"] as? String)
            .apply()
    }

    private fun prefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
    }
}
