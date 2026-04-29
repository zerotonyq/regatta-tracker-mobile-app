import '../domain/judge_flow_failure.dart';

class JudgeFlowValidator {
  const JudgeFlowValidator();

  void validateCreateRace({
    required List<int> participantIds,
    required List<int> judgeIds,
  }) {
    final uniqueParticipants = participantIds.toSet();
    final uniqueJudges = judgeIds.toSet();

    if (uniqueParticipants.length < 3) {
      throw const JudgeFlowFailure(
        'At least 3 unique participant ids are required.',
      );
    }
    if (uniqueJudges.isEmpty) {
      throw const JudgeFlowFailure('At least 1 judge id is required.');
    }
    if (uniqueParticipants.length != participantIds.length) {
      throw const JudgeFlowFailure('Participant ids must be unique.');
    }
    if (uniqueJudges.length != judgeIds.length) {
      throw const JudgeFlowFailure('Judge ids must be unique.');
    }
    final intersection = uniqueParticipants.intersection(uniqueJudges);
    if (intersection.isNotEmpty) {
      throw JudgeFlowFailure(
        'Participant and judge ids must not overlap: ${intersection.join(', ')}.',
      );
    }
  }
}
