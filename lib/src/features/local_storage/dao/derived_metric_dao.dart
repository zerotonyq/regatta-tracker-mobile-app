part of '../database/app_database.dart';

@DriftAccessor(tables: [DerivedMetrics])
class DerivedMetricDao extends DatabaseAccessor<AppDatabase>
    with _$DerivedMetricDaoMixin {
  DerivedMetricDao(super.db);

  Future<void> insertMetrics(List<DerivedMetricEntity> metrics) async {
    if (metrics.isEmpty) {
      return;
    }

    await batch((Batch batch) {
      batch.insertAll(
        derivedMetrics,
        metrics
            .map((DerivedMetricEntity metric) {
              return DerivedMetricsCompanion.insert(
                sessionId: metric.sessionId,
                timestampUtc: metric.timestampUtc,
                metricType: metric.metricType,
                metricValue: metric.metricValue,
                unit: Value(metric.unit),
              );
            })
            .toList(growable: false),
      );
    });
  }

  Future<List<DerivedMetricEntity>> loadMetricsForSession(
    int sessionId, {
    int? limit,
  }) async {
    final statement = select(derivedMetrics)
      ..where((tbl) => tbl.sessionId.equals(sessionId))
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.timestampUtc, mode: OrderingMode.desc),
      ]);
    if (limit != null) {
      statement.limit(limit);
    }
    final rows = await statement.get();

    return rows
        .map(
          (DerivedMetric row) => DerivedMetricEntity(
            id: row.id,
            sessionId: row.sessionId,
            timestampUtc: row.timestampUtc,
            metricType: row.metricType,
            metricValue: row.metricValue,
            unit: row.unit,
          ),
        )
        .toList(growable: false);
  }
}
