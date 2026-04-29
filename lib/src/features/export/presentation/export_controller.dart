import 'package:flutter/foundation.dart';

import '../application/export_session_data_use_case.dart';
import '../domain/diagnostics_snapshot_entity.dart';
import '../domain/export_format.dart';
import '../domain/export_payload_entity.dart';
import '../domain/session_summary_entity.dart';

class ExportController extends ChangeNotifier {
  ExportController({required ExportSessionDataUseCase exportSessionDataUseCase})
    : _exportSessionDataUseCase = exportSessionDataUseCase;

  final ExportSessionDataUseCase _exportSessionDataUseCase;

  List<SessionSummaryEntity> _sessions = const <SessionSummaryEntity>[];
  DiagnosticsSnapshotEntity? _diagnostics;
  ExportPayloadEntity? _lastExport;
  bool _loading = false;
  String? _error;

  List<SessionSummaryEntity> get sessions => _sessions;
  DiagnosticsSnapshotEntity? get diagnostics => _diagnostics;
  ExportPayloadEntity? get lastExport => _lastExport;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    await _run(() async {
      _sessions = await _exportSessionDataUseCase.loadCompletedSessions();
      _diagnostics = await _exportSessionDataUseCase.loadDiagnostics();
    });
  }

  Future<void> export({
    required int sessionId,
    required ExportFormat format,
  }) async {
    await _run(() async {
      _lastExport = await _exportSessionDataUseCase.execute(
        sessionId: sessionId,
        format: format,
      );
      _sessions = await _exportSessionDataUseCase.loadCompletedSessions();
    });
  }

  Future<void> exportDiagnostics({int? sessionId}) async {
    await _run(() async {
      _lastExport = await _exportSessionDataUseCase.execute(
        sessionId: sessionId ?? (_sessions.firstOrNull?.sessionId ?? 0),
        format: ExportFormat.diagnosticsJson,
      );
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
