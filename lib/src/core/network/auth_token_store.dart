import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/app_role.dart';

abstract class AuthTokenStore {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<AppRole?> readRole();
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> writeRole(AppRole role);
  Future<void> clear();
}

class SecureAuthTokenStore implements AuthTokenStore {
  const SecureAuthTokenStore(this._storage);

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _roleKey = 'auth.role';

  final FlutterSecureStorage _storage;

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _roleKey);
  }

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<AppRole?> readRole() async {
    final storedValue = await _storage.read(key: _roleKey);
    if (storedValue == null) {
      return null;
    }

    for (final role in AppRole.values) {
      if (role.name == storedValue) {
        return role;
      }
    }

    return null;
  }

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> writeRole(AppRole role) =>
      _storage.write(key: _roleKey, value: role.name);
}

class InMemoryAuthTokenStore implements AuthTokenStore {
  String? _accessToken;
  String? _refreshToken;
  AppRole? _role;

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _role = null;
  }

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<AppRole?> readRole() async => _role;

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> writeRole(AppRole role) async {
    _role = role;
  }
}
