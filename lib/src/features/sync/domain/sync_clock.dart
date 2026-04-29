class SyncClock {
  const SyncClock();

  DateTime nowUtc() => DateTime.now().toUtc();
}
