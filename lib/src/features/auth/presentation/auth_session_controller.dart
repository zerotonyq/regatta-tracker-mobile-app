import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/domain/app_role.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_failure.dart';
import '../../../core/network/auth_token_store.dart';
import '../../../core/network/network_failure.dart';
import '../../api/models/api_models.dart';
import '../data/auth_remote_data_source.dart';
import 'auth_session_state.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController({
    required AuthRemoteDataSource authRemoteDataSource,
    required AuthTokenStore tokenStore,
  }) : _authRemoteDataSource = authRemoteDataSource,
       _tokenStore = tokenStore;

  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthTokenStore _tokenStore;

  AuthSessionState _state = const AuthSessionState.unauthenticated();
  bool _isBusy = false;
  Future<void>? _refreshInFlight;

  AuthSessionState get state => _state;
  AuthSessionStatus get status => _state.status;
  AppRole? get selectedRole => _state.selectedRole;
  int? get userId => _state.userId;
  bool get isAuthenticated => _state.isAuthenticated;
  bool get isLoading =>
      _isBusy ||
      status == AuthSessionStatus.restoring ||
      status == AuthSessionStatus.refreshing;
  String? get error => _state.error;

  Future<void> login({required String login, required String password}) async {
    _setBusy(true);
    _setState(
      _state.copyWith(
        status: AuthSessionStatus.unauthenticated,
        clearError: true,
      ),
    );

    try {
      final tokens = await _authRemoteDataSource.login(
        login: login,
        password: password,
      );
      final role = _decodeAppRole(tokens.accessToken);
      if (role == null) {
        await _tokenStore.clear();
        _setState(
          const AuthSessionState.unauthenticated(
            error: 'Authenticated token does not contain a supported role.',
          ),
        );
        return;
      }
      await _tokenStore.writeRole(role);
      _setState(
        AuthSessionState(
          status: AuthSessionStatus.authenticated,
          selectedRole: role,
          userId: _decodeUserId(tokens.accessToken),
        ),
      );
    } on ApiException catch (failure) {
      _setState(AuthSessionState.unauthenticated(error: failure.message));
    } catch (failure) {
      _setState(AuthSessionState.unauthenticated(error: failure.toString()));
    } finally {
      _setBusy(false);
    }
  }

  Future<void> register({
    required String name,
    required String surname,
    required String login,
    required String password,
    required AppRole role,
  }) async {
    _setBusy(true);
    _setState(
      _state.copyWith(
        status: AuthSessionStatus.unauthenticated,
        clearError: true,
      ),
    );

    try {
      await _authRemoteDataSource.register(
        name: name,
        surname: surname,
        role: role == AppRole.judge ? UserRole.judge : UserRole.participant,
        login: login,
        password: password,
      );
      final tokens = await _authRemoteDataSource.login(
        login: login,
        password: password,
      );
      final authenticatedRole = _decodeAppRole(tokens.accessToken) ?? role;
      await _tokenStore.writeRole(authenticatedRole);
      _setState(
        AuthSessionState(
          status: AuthSessionStatus.authenticated,
          selectedRole: authenticatedRole,
          userId: _decodeUserId(tokens.accessToken),
        ),
      );
    } on ApiException catch (failure) {
      _setState(
        AuthSessionState.unauthenticated(
          selectedRole: role,
          error: failure.message,
        ),
      );
    } catch (failure) {
      _setState(
        AuthSessionState.unauthenticated(
          selectedRole: role,
          error: failure.toString(),
        ),
      );
    } finally {
      _setBusy(false);
    }
  }

  Future<void> restoreSession() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _setState(const AuthSessionState.unauthenticated());
      return;
    }

    _setState(
      _state.copyWith(status: AuthSessionStatus.restoring, clearError: true),
    );

    try {
      await refreshSession(
        correlationId: 'session-restore',
        updateStateOnNetworkFailure: true,
        showRefreshingState: false,
      );
    } on NetworkFailure catch (failure) {
      _setState(
        AuthSessionState(
          status: AuthSessionStatus.failure,
          selectedRole: selectedRole,
          error: failure.message,
        ),
      );
    } on ApiException catch (failure) {
      if (failure.statusCode == 400 || failure.statusCode == 401) {
        await _tokenStore.clear();
        _setState(const AuthSessionState.unauthenticated());
      } else {
        _setState(
          AuthSessionState(
            status: AuthSessionStatus.failure,
            selectedRole: selectedRole,
            error: failure.message,
          ),
        );
      }
    }
  }

  Future<void> refreshSession({
    String? correlationId,
    bool updateStateOnNetworkFailure = false,
    bool showRefreshingState = true,
  }) {
    final refresh = _refreshInFlight;
    if (refresh != null) {
      return refresh;
    }

    final future = _refreshSessionImpl(
      correlationId: correlationId,
      updateStateOnNetworkFailure: updateStateOnNetworkFailure,
      showRefreshingState: showRefreshingState,
    );
    _refreshInFlight = future.whenComplete(() => _refreshInFlight = null);
    return _refreshInFlight!;
  }

  Future<void> handleTerminalAuthFailure(AuthFailure failure) async {
    await _tokenStore.clear();
    _setState(
      AuthSessionState(
        status: AuthSessionStatus.expired,
        error: failure.message,
      ),
    );
  }

  Future<void> logout() async {
    await _tokenStore.clear();
    _setState(const AuthSessionState.unauthenticated());
  }

  void clearError() {
    if (error == null) {
      return;
    }

    _setState(_state.copyWith(clearError: true));
  }

  Future<void> _refreshSessionImpl({
    String? correlationId,
    required bool updateStateOnNetworkFailure,
    required bool showRefreshingState,
  }) async {
    final currentRole =
        selectedRole ??
        await _tokenStore.readRole() ??
        await _readRoleFromStoredAccessToken();

    final previousStatus = status;
    if (showRefreshingState) {
      _setState(
        AuthSessionState(
          status: previousStatus == AuthSessionStatus.restoring
              ? AuthSessionStatus.restoring
              : AuthSessionStatus.refreshing,
          selectedRole: currentRole,
        ),
      );
    }

    try {
      final tokens = await _authRemoteDataSource.refresh(
        correlationId: correlationId,
      );
      final role = _decodeAppRole(tokens.accessToken);
      if (role == null) {
        final failure = AuthFailure(
          type: AuthFailureType.sessionExpired,
          statusCode: 401,
          message: 'Authenticated token does not contain a supported role.',
        );
        await handleTerminalAuthFailure(failure);
        throw failure;
      }
      await _tokenStore.writeRole(role);
      _setState(
        AuthSessionState(
          status: AuthSessionStatus.authenticated,
          selectedRole: role,
          userId: _decodeUserId(tokens.accessToken),
        ),
      );
    } on NetworkFailure catch (failure) {
      if (updateStateOnNetworkFailure) {
        _setState(
          AuthSessionState(
            status: AuthSessionStatus.failure,
            selectedRole: currentRole,
            error: failure.message,
          ),
        );
      } else if (showRefreshingState) {
        _setState(
          AuthSessionState(
            status: AuthSessionStatus.authenticated,
            selectedRole: currentRole,
          ),
        );
      }
      rethrow;
    } on AuthFailure catch (failure) {
      if (failure.isTerminal ||
          failure.statusCode == 400 ||
          failure.statusCode == 401) {
        await handleTerminalAuthFailure(
          AuthFailure(
            type: AuthFailureType.sessionExpired,
            statusCode: failure.statusCode,
            message: failure.message,
            rawBody: failure.rawBody,
          ),
        );
      } else if (showRefreshingState) {
        _setState(
          AuthSessionState(
            status: AuthSessionStatus.authenticated,
            selectedRole: currentRole,
            error: failure.message,
          ),
        );
      }
      rethrow;
    } on ApiException catch (failure) {
      if (failure.statusCode == 400 || failure.statusCode == 401) {
        await handleTerminalAuthFailure(
          AuthFailure(
            type: AuthFailureType.sessionExpired,
            statusCode: failure.statusCode,
            message: failure.message,
            rawBody: failure.rawBody,
          ),
        );
      } else if (updateStateOnNetworkFailure) {
        _setState(
          AuthSessionState(
            status: AuthSessionStatus.failure,
            selectedRole: currentRole,
            error: failure.message,
          ),
        );
      } else if (showRefreshingState) {
        _setState(
          AuthSessionState(
            status: AuthSessionStatus.authenticated,
            selectedRole: currentRole,
            error: failure.message,
          ),
        );
      }
      rethrow;
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  void _setState(AuthSessionState nextState) {
    _state = nextState;
    notifyListeners();
  }

  int? _decodeUserId(String token) {
    final payload = _decodePayload(token);
    if (payload == null) {
      return null;
    }

    final sub = payload['sub'];
    if (sub is num) {
      return sub.toInt();
    }
    if (sub is String) {
      return int.tryParse(sub);
    }
    return null;
  }

  Future<AppRole?> _readRoleFromStoredAccessToken() async {
    final accessToken = await _tokenStore.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }
    return _decodeAppRole(accessToken);
  }

  AppRole? _decodeAppRole(String token) {
    final payload = _decodePayload(token);
    if (payload == null) {
      return null;
    }

    final directRole = _parseRoleValue(payload['role']);
    if (directRole != null) {
      return directRole;
    }

    final nestedRoleKeys = <String>[
      'roles',
      'authorities',
      'app_role',
      'user_role',
    ];
    for (final key in nestedRoleKeys) {
      final parsedRole = _parseRoleValue(payload[key]);
      if (parsedRole != null) {
        return parsedRole;
      }
    }
    return null;
  }

  AppRole? _parseRoleValue(Object? value) {
    if (value is String) {
      return _mapRoleName(value);
    }

    if (value is Iterable<Object?>) {
      for (final item in value) {
        final role = _parseRoleValue(item);
        if (role != null) {
          return role;
        }
      }
    }

    return null;
  }

  AppRole? _mapRoleName(String rawRole) {
    final normalized = rawRole.trim().toLowerCase();
    if (normalized == 'judge' || normalized == 'role_judge') {
      return AppRole.judge;
    }
    if (normalized == 'participant' || normalized == 'role_participant') {
      return AppRole.participant;
    }
    return null;
  }

  Map<String, Object?>? _decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      return null;
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      return jsonDecode(utf8.decode(base64Url.decode(normalized)))
          as Map<String, Object?>;
    } catch (_) {
      return null;
    }
  }
}
