class JudgeFlowFailure implements Exception {
  const JudgeFlowFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
