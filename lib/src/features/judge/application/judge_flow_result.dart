import '../domain/judge_race_context_entity.dart';

class JudgeFlowResult<T> {
  const JudgeFlowResult({
    required this.context,
    required this.message,
    this.value,
  });

  final T? value;
  final JudgeRaceContextEntity context;
  final String message;
}
