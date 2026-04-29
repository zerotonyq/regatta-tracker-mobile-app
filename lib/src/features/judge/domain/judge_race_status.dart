enum JudgeRaceStatus { idle, created, started, finished }

extension JudgeRaceStatusWire on JudgeRaceStatus {
  String get wireName => switch (this) {
    JudgeRaceStatus.idle => 'idle',
    JudgeRaceStatus.created => 'created',
    JudgeRaceStatus.started => 'started',
    JudgeRaceStatus.finished => 'finished',
  };
}

JudgeRaceStatus judgeRaceStatusFromWire(String? rawValue) {
  return JudgeRaceStatus.values.firstWhere(
    (JudgeRaceStatus status) => status.wireName == rawValue,
    orElse: () => JudgeRaceStatus.idle,
  );
}
