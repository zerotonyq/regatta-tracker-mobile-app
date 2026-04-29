package com.regatta.regatta_sensor_bridge

import android.content.Context
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream

internal class RegattaTrackingStore(private val context: Context) {
    private val rootDir: File by lazy {
        File(context.filesDir, "regatta_sensor_bridge").apply { mkdirs() }
    }

    fun rootPath(): String = rootDir.absolutePath

    fun sessionPath(sessionId: String): String = sessionDir(sessionId).absolutePath

    fun appendGpsPoint(sessionId: String, payload: Map<String, Any?>) {
        appendJsonLine(File(sessionDir(sessionId), "gps_points.ndjson"), payload)
    }

    fun appendHealth(sessionId: String?, payload: Map<String, Any?>) {
        val file = if (sessionId == null) {
            File(rootDir, "health_events.ndjson")
        } else {
            File(sessionDir(sessionId), "health_events.ndjson")
        }
        appendJsonLine(file, payload)
    }

    fun flushImuChunk(
        sessionId: String,
        chunkStartedAtMillis: Long,
        sampleCount: Int,
        bytes: ByteArrayOutputStream,
    ): Map<String, Any?> {
        val imuDir = File(sessionDir(sessionId), "imu").apply { mkdirs() }
        val chunkId = "imu_${chunkStartedAtMillis}.bin"
        val target = File(imuDir, chunkId)
        FileOutputStream(target).use { output ->
            bytes.writeTo(output)
        }
        return mapOf(
            "chunkId" to chunkId.removeSuffix(".bin"),
            "startedAt" to iso8601(chunkStartedAtMillis),
            "sampleCount" to sampleCount,
            "storagePath" to target.absolutePath,
        )
    }

    private fun appendJsonLine(file: File, payload: Map<String, Any?>) {
        file.parentFile?.mkdirs()
        file.appendText(JSONObject(payload).toString() + "\n")
    }

    private fun sessionDir(sessionId: String): File {
        return File(rootDir, "session_$sessionId").apply { mkdirs() }
    }
}
