part of '../database/app_database.dart';

@DriftAccessor(tables: [ImuChunks])
class ImuChunkDao extends DatabaseAccessor<AppDatabase>
    with _$ImuChunkDaoMixin {
  ImuChunkDao(super.db);

  Future<void> insertChunk(ImuChunkEntity chunk) async {
    await into(imuChunks).insert(
      ImuChunksCompanion.insert(
        sessionId: chunk.sessionId,
        capturedAtUtc: chunk.capturedAtUtc,
        chunkStartMonotonicNs: chunk.chunkStartMonotonicNs,
        sampleCount: chunk.sampleCount,
        samplingHz: chunk.samplingHz,
        payload: chunk.payload,
        payloadFormat: Value(chunk.payloadFormat),
      ),
    );
  }

  Future<bool> existsChunkForSessionAt({
    required int sessionId,
    required DateTime capturedAtUtc,
  }) async {
    final row =
        await (select(imuChunks)
              ..where((tbl) => tbl.sessionId.equals(sessionId))
              ..where((tbl) => tbl.capturedAtUtc.equals(capturedAtUtc))
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<(int chunkCount, int sampleCount)> summarizeForSession(
    int sessionId,
  ) async {
    final chunkCountExpression = imuChunks.id.count();
    final sampleCountExpression = imuChunks.sampleCount.sum();
    final row =
        await (selectOnly(imuChunks)
              ..addColumns([chunkCountExpression, sampleCountExpression])
              ..where(imuChunks.sessionId.equals(sessionId)))
            .getSingle();
    return (
      row.read(chunkCountExpression) ?? 0,
      row.read(sampleCountExpression) ?? 0,
    );
  }

  Future<List<ImuChunkEntity>> loadChunksForSession(int sessionId) async {
    final rows =
        await (select(imuChunks)
              ..where((tbl) => tbl.sessionId.equals(sessionId))
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.capturedAtUtc,
                  mode: OrderingMode.asc,
                ),
              ]))
            .get();

    return rows
        .map(
          (ImuChunk row) => ImuChunkEntity(
            id: row.id,
            sessionId: row.sessionId,
            capturedAtUtc: row.capturedAtUtc,
            chunkStartMonotonicNs: row.chunkStartMonotonicNs,
            sampleCount: row.sampleCount,
            samplingHz: row.samplingHz,
            payload: row.payload,
            payloadFormat: row.payloadFormat,
          ),
        )
        .toList(growable: false);
  }
}
