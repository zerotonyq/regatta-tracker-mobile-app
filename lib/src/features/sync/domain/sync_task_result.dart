enum SyncTaskResultType { synced, retryableFailure, terminalFailure }

class SyncTaskResult {
  const SyncTaskResult._({required this.type, this.message});

  final SyncTaskResultType type;
  final String? message;

  const SyncTaskResult.synced() : this._(type: SyncTaskResultType.synced);

  const SyncTaskResult.retryableFailure(String message)
    : this._(type: SyncTaskResultType.retryableFailure, message: message);

  const SyncTaskResult.terminalFailure(String message)
    : this._(type: SyncTaskResultType.terminalFailure, message: message);
}
