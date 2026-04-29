import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../domain/connectivity_monitor.dart';

class PollingConnectivityMonitor implements ConnectivityMonitor {
  PollingConnectivityMonitor({
    Duration probeInterval = const Duration(seconds: 15),
    InternetLookup? internetLookup,
  }) : _probeInterval = probeInterval,
       _internetLookup =
           internetLookup ?? ((String host) => InternetAddress.lookup(host));

  final Duration _probeInterval;
  final InternetLookup _internetLookup;
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  Timer? _probeTimer;
  bool? _lastKnownStatus;

  @override
  Future<bool> isOnline() async {
    if (kIsWeb) {
      _publish(true);
      _ensurePolling();
      return true;
    }

    try {
      final addresses = await _internetLookup('example.com');
      final isOnline = addresses.isNotEmpty;
      _publish(isOnline);
      _ensurePolling();
      return isOnline;
    } on SocketException {
      _publish(false);
      _ensurePolling();
      return false;
    }
  }

  @override
  Stream<bool> watchStatus() {
    _ensurePolling();
    return _statusController.stream;
  }

  void dispose() {
    _probeTimer?.cancel();
    _statusController.close();
  }

  void _ensurePolling() {
    _probeTimer ??= Timer.periodic(_probeInterval, (_) {
      unawaited(isOnline());
    });
  }

  void _publish(bool isOnline) {
    if (_lastKnownStatus == isOnline) {
      return;
    }
    _lastKnownStatus = isOnline;
    _statusController.add(isOnline);
  }
}

typedef InternetLookup = Future<List<InternetAddress>> Function(String host);
