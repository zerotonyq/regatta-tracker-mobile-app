import 'export_payload_entity.dart';
import 'diagnostics_snapshot_entity.dart';
import 'export_format.dart';
import 'session_summary_entity.dart';

abstract class ExportRepository {
  Future<List<SessionSummaryEntity>> loadCompletedSessions();

  Future<SessionSummaryEntity?> loadSessionSummary(int sessionId);

  Future<DiagnosticsSnapshotEntity> buildDiagnostics({int? sessionId});

  Future<ExportPayloadEntity> buildExport({
    required int sessionId,
    required ExportFormat format,
  });
}
