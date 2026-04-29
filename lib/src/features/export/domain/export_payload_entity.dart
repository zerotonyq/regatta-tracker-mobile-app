import 'export_format.dart';

class ExportPayloadEntity {
  const ExportPayloadEntity({
    required this.fileName,
    required this.bytes,
    required this.filePath,
    required this.format,
    required this.sessionId,
    required this.jobState,
    this.diagnosticsTag,
  });

  final String fileName;
  final List<int> bytes;
  final String filePath;
  final ExportFormat format;
  final int sessionId;
  final String jobState;
  final String? diagnosticsTag;
}
