abstract class JudgeUsersRepository {
  Future<List<int>> loadAvailableJudgeUserIds();

  Future<List<int>> loadAvailableParticipantUserIds();
}
