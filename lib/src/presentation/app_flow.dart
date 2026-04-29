import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/domain/app_role.dart';
import '../di/app_dependencies.dart';
import '../features/auth/presentation/auth_bootstrap_controller.dart';
import '../features/auth/presentation/auth_session_controller.dart';
import '../features/auth/presentation/auth_session_state.dart';
import '../features/export/presentation/export_controller.dart';
import '../features/judge/presentation/judge_race_controller.dart';
import '../features/race_computer/presentation/race_computer_controller.dart';
import '../features/tracking/domain/tracking_session_entity.dart';
import '../features/tracking/presentation/tracking_session_controller.dart';
import 'auth/login_page.dart';
import 'auth/register_page.dart';
import 'auth/session_restore_page.dart';
import 'judge/judge_create_race_page.dart';
import 'judge/judge_dashboard_page.dart';
import 'participant/participant_dashboard_page.dart';
import 'participant/racing_mode_page.dart';
import 'participant/session_history_page.dart';

enum _FlowScreen {
  login,
  register,
  judgeDashboard,
  judgeCreateRace,
  participantDashboard,
  participantRacing,
  participantHistory,
}

class AppFlow extends StatefulWidget {
  const AppFlow({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  static const _permissionsRequestedKey = 'runtime_permissions_requested_v1';

  late final AuthSessionController _authController;
  late final AuthBootstrapController _bootstrapController;
  late final JudgeRaceController _judgeController;
  late final TrackingSessionController _trackingController;
  late final RaceComputerController _raceComputerController;
  late final ExportController _exportController;

  _FlowScreen _screen = _FlowScreen.login;
  bool _hasTriggeredTrackingRestore = false;
  bool _hasTriggeredJudgeRestore = false;
  bool _hasTriggeredPermissionBootstrap = false;

  @override
  void initState() {
    super.initState();
    _authController = widget.dependencies.authSessionController
      ..addListener(_handleAuthState);
    _bootstrapController = widget.dependencies.authBootstrapController
      ..addListener(_handleBootstrapState);
    _judgeController = widget.dependencies.createJudgeRaceController();
    _trackingController = widget.dependencies.createTrackingSessionController()
      ..addListener(_handleTrackingState);
    _raceComputerController = widget.dependencies
        .createRaceComputerController();
    _exportController = widget.dependencies.createExportController();
    unawaited(_bootstrapPermissionsAndHealth());
    unawaited(widget.dependencies.ensureSyncWorkerStarted());
    _bootstrapController.bootstrap();
  }

  @override
  void dispose() {
    _authController.removeListener(_handleAuthState);
    _bootstrapController.removeListener(_handleBootstrapState);
    _trackingController.removeListener(_handleTrackingState);
    _judgeController.dispose();
    _trackingController.dispose();
    _raceComputerController.dispose();
    _exportController.dispose();
    unawaited(widget.dependencies.disposeBackgroundTasks());
    super.dispose();
  }

  void _handleAuthState() {
    if (_authController.isAuthenticated) {
      final role = _authController.selectedRole;
      if (role == AppRole.judge) {
        if (!_hasTriggeredJudgeRestore) {
          _hasTriggeredJudgeRestore = true;
          unawaited(_judgeController.restore());
        }
        _setScreen(_FlowScreen.judgeDashboard);
      } else if (role == AppRole.participant) {
        if (!_hasTriggeredTrackingRestore) {
          _hasTriggeredTrackingRestore = true;
          unawaited(_trackingController.restore());
        }
        _setScreen(
          _hasOngoingTrackingSession(_trackingController.state)
              ? _FlowScreen.participantRacing
              : _FlowScreen.participantDashboard,
        );
      }
      return;
    }

    if (_authController.status == AuthSessionStatus.expired) {
      _hasTriggeredTrackingRestore = false;
      _hasTriggeredJudgeRestore = false;
      _setScreen(_FlowScreen.login);
      return;
    }

    _hasTriggeredTrackingRestore = false;
    _hasTriggeredJudgeRestore = false;
    if (_isProtectedScreen(_screen)) {
      _setScreen(_FlowScreen.login);
    } else {
      _safeSetState();
    }
  }

  void _handleBootstrapState() {
    if (!mounted) {
      return;
    }
    _safeSetState();
  }

  void _handleTrackingState() {
    if (!mounted || _authController.selectedRole != AppRole.participant) {
      return;
    }

    if (_hasOngoingTrackingSession(_trackingController.state)) {
      _setScreen(_FlowScreen.participantRacing);
      return;
    }

    if (_screen == _FlowScreen.participantRacing &&
        (_trackingController.state == TrackingSessionState.completed ||
            _trackingController.state == TrackingSessionState.failed ||
            _trackingController.state == TrackingSessionState.idle)) {
      _setScreen(_FlowScreen.participantDashboard);
      return;
    }

    _safeSetState();
  }

  void _setScreen(_FlowScreen nextScreen) {
    if (_screen == nextScreen) {
      _safeSetState();
      return;
    }
    _safeSetState(() {
      _screen = nextScreen;
    });
  }

  void _safeSetState([VoidCallback? fn]) {
    if (!mounted) {
      return;
    }
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(fn ?? () {});
      });
      return;
    }
    setState(fn ?? () {});
  }

  bool _hasOngoingTrackingSession(TrackingSessionState state) {
    return state == TrackingSessionState.preparing ||
        state == TrackingSessionState.tracking ||
        state == TrackingSessionState.paused ||
        state == TrackingSessionState.syncing;
  }

  bool _isProtectedScreen(_FlowScreen screen) {
    return screen == _FlowScreen.judgeDashboard ||
        screen == _FlowScreen.judgeCreateRace ||
        screen == _FlowScreen.participantDashboard ||
        screen == _FlowScreen.participantRacing;
  }

  Future<void> _bootstrapPermissionsAndHealth() async {
    if (_hasTriggeredPermissionBootstrap) {
      return;
    }
    _hasTriggeredPermissionBootstrap = true;

    final settingsDao = widget.dependencies.appDatabase.appSettingsDao;
    final wasRequested = await settingsDao.readValue(_permissionsRequestedKey);

    try {
      await _trackingController.requestRequiredPermissions();
      if (wasRequested != 'true') {
        await settingsDao.writeValue(
          key: _permissionsRequestedKey,
          value: 'true',
          updatedAtUtc: DateTime.now().toUtc(),
        );
      }
    } catch (_) {
      _hasTriggeredPermissionBootstrap = false;
      return;
    }

    if (!mounted) {
      return;
    }
    await _trackingController.refreshHealth();
  }

  Future<void> _logout() async {
    await _authController.logout();
    if (!mounted) {
      return;
    }
    _setScreen(_FlowScreen.login);
  }

  @override
  Widget build(BuildContext context) {
    if (!_bootstrapController.hasCompletedBootstrap ||
        _bootstrapController.isBootstrapping ||
        _authController.status == AuthSessionStatus.restoring ||
        _authController.status == AuthSessionStatus.failure) {
      return SessionRestorePage(
        controller: _authController,
        bootstrapController: _bootstrapController,
      );
    }

    return switch (_screen) {
      _FlowScreen.login => LoginPage(
        controller: _authController,
        onBack: null,
        onOpenRegister: () => setState(() => _screen = _FlowScreen.register),
      ),
      _FlowScreen.register => RegisterPage(
        controller: _authController,
        onBack: () => setState(() => _screen = _FlowScreen.login),
        onOpenLogin: () => setState(() => _screen = _FlowScreen.login),
      ),
      _FlowScreen.judgeDashboard => JudgeDashboardPage(
        authController: _authController,
        controller: _judgeController,
        onCreateRaceTap: () =>
            setState(() => _screen = _FlowScreen.judgeCreateRace),
        onLogoutTap: _logout,
      ),
      _FlowScreen.judgeCreateRace => JudgeCreateRacePage(
        authController: _authController,
        controller: _judgeController,
        onBack: () => setState(() => _screen = _FlowScreen.judgeDashboard),
        onCreated: () => setState(() => _screen = _FlowScreen.judgeDashboard),
      ),
      _FlowScreen.participantDashboard => ParticipantDashboardPage(
        authController: _authController,
        trackingController: _trackingController,
        managementRemoteDataSource: widget.dependencies.managementRemoteDataSource,
        onStartRacing: () =>
            setState(() => _screen = _FlowScreen.participantRacing),
        onOpenHistory: () =>
            setState(() => _screen = _FlowScreen.participantHistory),
        onLogoutTap: _logout,
      ),
      _FlowScreen.participantRacing => RacingModePage(
        controller: _trackingController,
        raceComputerController: _raceComputerController,
        onBack: () =>
            setState(() => _screen = _FlowScreen.participantDashboard),
      ),
      _FlowScreen.participantHistory => SessionHistoryPage(
        controller: _exportController,
        onBack: () =>
            setState(() => _screen = _FlowScreen.participantDashboard),
      ),
    };
  }
}
