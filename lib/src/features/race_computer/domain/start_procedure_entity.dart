class StartProcedureEntity {
  const StartProcedureEntity({
    required this.phase,
    required this.configuredAtUtc,
    required this.startAtUtc,
    required this.durationSeconds,
    required this.remainingSeconds,
    required this.progress,
    required this.statusMessage,
    this.lastSignalType,
    this.lastSignalAtUtc,
    this.cue = StartProcedureCue.none,
  });

  final String phase;
  final DateTime configuredAtUtc;
  final DateTime startAtUtc;
  final int durationSeconds;
  final int remainingSeconds;
  final double progress;
  final String statusMessage;
  final String? lastSignalType;
  final DateTime? lastSignalAtUtc;
  final StartProcedureCue cue;

  bool get isActive => remainingSeconds > 0;
}

enum StartProcedureCue { none, warning, preparatory, oneMinute, start }
