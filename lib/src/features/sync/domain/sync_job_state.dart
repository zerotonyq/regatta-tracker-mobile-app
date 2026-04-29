enum SyncJobState {
  pending,
  inProgress,
  synced,
  failedRetryable,
  failedTerminal,
}

extension SyncJobStateWire on SyncJobState {
  String get wireName => switch (this) {
    SyncJobState.pending => 'pending',
    SyncJobState.inProgress => 'in_progress',
    SyncJobState.synced => 'synced',
    SyncJobState.failedRetryable => 'failed_retryable',
    SyncJobState.failedTerminal => 'failed_terminal',
  };
}

SyncJobState syncJobStateFromWire(String value) {
  return SyncJobState.values.firstWhere(
    (SyncJobState state) => state.wireName == value,
    orElse: () => SyncJobState.pending,
  );
}
