import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

import '../application/tracking_session_service.dart';
import '../domain/tracking_health.dart';
import '../domain/tracking_session_entity.dart';
import '../domain/tracking_session_failure.dart';

class TrackingSessionController extends ChangeNotifier {
  TrackingSessionController({
    required TrackingSessionService trackingSessionService,
  }) : _trackingSessionService = trackingSessionService;

  final TrackingSessionService _trackingSessionService;

  StreamSubscription<TrackingHealth>? _healthSubscription;
  TrackingSessionEntity? _session;
  TrackingHealth _health = TrackingHealth.unknown;
  bool _loading = false;
  String? _error;

  TrackingSessionEntity? get session => _session;
  TrackingSessionState get state =>
      _session?.state ?? TrackingSessionState.idle;
  TrackingHealth get health => _health;
  bool get loading => _loading;
  String? get error => _error;
  int? get raceId => _session?.raceId;
  TrackingProfile? get activeTrackingProfile =>
      _health.activeTrackingProfile ??
      switch (_session?.state) {
        TrackingSessionState.paused => TrackingProfile.paused,
        TrackingSessionState.tracking => TrackingProfile.raceCruise,
        _ => null,
      };

  Future<void> start({required int raceId}) async {
    await _runBusy(() async {
      final snapshot = await _trackingSessionService.start(
        raceId: raceId,
        role: 'participant',
      );
      _session = snapshot.session;
      _health = snapshot.health;
      await _bindHealthStream();
      _error = null;
    });
  }

  Future<void> pause() async {
    final session = _session;
    if (session == null) {
      return;
    }

    await _runBusy(() async {
      final snapshot = await _trackingSessionService.pause(session);
      _session = snapshot.session;
      _health = snapshot.health;
      await _bindHealthStream();
      _error = null;
    });
  }

  Future<void> resume() async {
    final session = _session;
    if (session == null) {
      return;
    }

    await _runBusy(() async {
      final snapshot = await _trackingSessionService.resume(session);
      _session = snapshot.session;
      _health = snapshot.health;
      await _bindHealthStream();
      _error = null;
    });
  }

  Future<void> stop() async {
    final session = _session;
    if (session == null) {
      return;
    }

    await _runBusy(() async {
      final snapshot = await _trackingSessionService.stop(session);
      _session = snapshot.session;
      _health = snapshot.health;
      await _bindHealthStream();
      _error = null;
    });
  }

  Future<void> restore() async {
    await _runBusy(() async {
      final snapshot = await _trackingSessionService.restore();
      _session = snapshot?.session;
      _health =
          snapshot?.health ??
          await _trackingSessionService.refreshHealth(sessionId: _session?.id);
      await _bindHealthStream();
      _error = null;
    });
  }

  Future<void> refreshHealth() async {
    _health = await _trackingSessionService.refreshHealth(
      sessionId: _session?.id,
    );
    notifyListeners();
  }

  Future<void> requestRequiredPermissions() async {
    _health = await _trackingSessionService.requestRequiredPermissions();
    notifyListeners();
  }

  Future<void> setTrackingProfile(TrackingProfile profile) async {
    final session = _session;
    if (session == null) {
      return;
    }
    await _runBusy(() async {
      await _trackingSessionService.setTrackingProfile(
        session: session,
        profile: profile,
      );
      _health = await _trackingSessionService.refreshHealth(
        sessionId: session.id,
      );
      _error = null;
    });
  }

  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    _loading = true;
    notifyListeners();
    try {
      await action();
    } on TrackingSessionServiceException catch (error) {
      _session = error.session;
      _health = error.health;
      _error = error.message;
    } on TrackingSessionFailure catch (error) {
      _error = error.message;
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _bindHealthStream() async {
    await _healthSubscription?.cancel();
    _healthSubscription = _trackingSessionService
        .watchHealth(sessionId: _session?.id)
        .listen((TrackingHealth health) {
          _health = health;
          notifyListeners();
        });
  }

  @override
  void dispose() {
    unawaited(_healthSubscription?.cancel());
    _healthSubscription = null;
    super.dispose();
  }
}
