import '../../tracking/domain/derived_metric_entity.dart';
import '../domain/wind_estimate_entity.dart';
import 'geo_math.dart';

class WindEstimator {
  const WindEstimator({GeoMath geoMath = const GeoMath()}) : _geoMath = geoMath;

  final GeoMath _geoMath;

  WindEstimateEntity? estimate({required Map<String, double> latestMetrics}) {
    final heading = latestMetrics['heading_deg'];
    if (heading == null) {
      return null;
    }

    final heel = latestMetrics['heel_deg'] ?? 0;
    final magneticInstability =
        (latestMetrics['quality_magnetic_instability'] ?? 0) > 0.5;
    final insufficientSamples =
        (latestMetrics['quality_insufficient_samples'] ?? 0) > 0.5;
    final calibrationMissing =
        (latestMetrics['quality_calibration_missing'] ?? 0) > 0.5;
    final staleData = (latestMetrics['quality_stale_data'] ?? 0) > 0.5;

    final tackOffset = heel >= 0 ? -42.0 : 42.0;
    final direction = _geoMath.normalizeDegrees(heading + tackOffset);
    double confidence = 0.65;
    if ((latestMetrics['quality_heading_validated_by_gps'] ?? 0) > 0.5) {
      confidence += 0.15;
    }
    if (magneticInstability) {
      confidence -= 0.20;
    }
    if (insufficientSamples) {
      confidence -= 0.15;
    }
    if (calibrationMissing) {
      confidence -= 0.15;
    }
    if (staleData) {
      confidence -= 0.15;
    }

    final clampedConfidence = confidence.clamp(0.1, 0.95);
    final qualityLabel = clampedConfidence >= 0.75
        ? 'good'
        : clampedConfidence >= 0.5
        ? 'medium'
        : 'low';

    return WindEstimateEntity(
      directionDegrees: direction,
      confidence: clampedConfidence,
      source: 'derived_metrics_estimate',
      qualityLabel: qualityLabel,
    );
  }

  Map<String, double> latestMetricMap(List<DerivedMetricEntity> metrics) {
    final result = <String, double>{};
    for (final DerivedMetricEntity metric in metrics) {
      result.putIfAbsent(metric.metricType, () => metric.metricValue);
    }
    return result;
  }
}
