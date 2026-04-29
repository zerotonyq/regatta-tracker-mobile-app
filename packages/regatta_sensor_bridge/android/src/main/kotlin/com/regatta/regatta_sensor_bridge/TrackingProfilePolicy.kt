package com.regatta.regatta_sensor_bridge

internal data class GpsPolicy(
    val intervalMillis: Long,
    val minDistanceMeters: Float,
)

internal object TrackingProfilePolicy {
    fun gpsPolicy(profile: String): GpsPolicy {
        return when (profile) {
            "prestartPrecision" -> GpsPolicy(intervalMillis = 1_000, minDistanceMeters = 0f)
            "raceCruise" -> GpsPolicy(intervalMillis = 1_000, minDistanceMeters = 7f)
            "markRoundingPrecision" -> GpsPolicy(intervalMillis = 1_000, minDistanceMeters = 0f)
            "paused" -> GpsPolicy(intervalMillis = 0, minDistanceMeters = 0f)
            else -> GpsPolicy(intervalMillis = 1_000, minDistanceMeters = 5f)
        }
    }
}
