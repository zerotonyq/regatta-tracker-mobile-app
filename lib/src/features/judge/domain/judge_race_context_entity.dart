import 'judge_race_status.dart';

class JudgeRaceContextEntity {
  const JudgeRaceContextEntity({
    required this.status,
    this.lastRaceId,
    this.lastJudgeActionAtUtc,
  });

  final int? lastRaceId;
  final JudgeRaceStatus status;
  final DateTime? lastJudgeActionAtUtc;

  bool get hasActiveRace =>
      lastRaceId != null &&
      (status == JudgeRaceStatus.created || status == JudgeRaceStatus.started);

  JudgeRaceContextEntity copyWith({
    int? lastRaceId,
    JudgeRaceStatus? status,
    DateTime? lastJudgeActionAtUtc,
  }) {
    return JudgeRaceContextEntity(
      lastRaceId: lastRaceId ?? this.lastRaceId,
      status: status ?? this.status,
      lastJudgeActionAtUtc: lastJudgeActionAtUtc ?? this.lastJudgeActionAtUtc,
    );
  }

  static const empty = JudgeRaceContextEntity(status: JudgeRaceStatus.idle);
}
