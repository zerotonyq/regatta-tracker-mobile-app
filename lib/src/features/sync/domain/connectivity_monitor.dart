abstract class ConnectivityMonitor {
  Future<bool> isOnline();

  Stream<bool> watchStatus();
}
