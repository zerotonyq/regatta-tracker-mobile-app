import 'package:flutter/foundation.dart';

import 'auth_session_controller.dart';

class AuthBootstrapController extends ChangeNotifier {
  AuthBootstrapController({required AuthSessionController sessionController})
    : _sessionController = sessionController;

  final AuthSessionController _sessionController;

  bool _hasCompletedBootstrap = false;
  bool _isBootstrapping = false;

  bool get hasCompletedBootstrap => _hasCompletedBootstrap;
  bool get isBootstrapping => _isBootstrapping;

  Future<void> bootstrap() => _runRestore(markCompleted: true);

  Future<void> retryRestore() => _runRestore(markCompleted: true);

  Future<void> _runRestore({required bool markCompleted}) async {
    if (_isBootstrapping) {
      return;
    }

    _isBootstrapping = true;
    notifyListeners();

    try {
      await _sessionController.restoreSession();
    } finally {
      _isBootstrapping = false;
      if (markCompleted) {
        _hasCompletedBootstrap = true;
      }
      notifyListeners();
    }
  }
}
