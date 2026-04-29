import '../domain/diagnostics_snapshot_entity.dart';
import '../domain/export_format.dart';
import '../domain/export_payload_entity.dart';
import '../domain/export_repository.dart';
import '../domain/session_summary_entity.dart';

class ExportSessionDataUseCase {
  const ExportSessionDataUseCase(this._exportRepository);

  final ExportRepository _exportRepository;

  Future<List<SessionSummaryEntity>> loadCompletedSessions() {
    return _exportRepository.loadCompletedSessions();
  }

  Future<DiagnosticsSnapshotEntity> loadDiagnostics({int? sessionId}) {
    return _exportRepository.buildDiagnostics(sessionId: sessionId);
  }

  Future<ExportPayloadEntity> execute({
    required int sessionId,
    required ExportFormat format,
  }) {
    return _exportRepository.buildExport(sessionId: sessionId, format: format);
  }
}
