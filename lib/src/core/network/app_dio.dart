import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'auth_failure.dart';
import 'auth_token_store.dart';
import 'request_metadata_provider.dart';

typedef RefreshSessionCallback = Future<void> Function({String? correlationId});
typedef SessionExpiredCallback = Future<void> Function(AuthFailure failure);

class AppDio {
  static Dio createAuthClient({
    required AppConfig config,
    required RequestMetadataProvider metadataProvider,
  }) {
    final dio = _createBaseDio(config);
    dio.interceptors.add(_MetadataAndTracingInterceptor(metadataProvider));
    return dio;
  }

  static Dio createProtectedClient({
    required AppConfig config,
    required AuthTokenStore tokenStore,
    required RequestMetadataProvider metadataProvider,
    required RefreshSessionCallback refreshSession,
    required SessionExpiredCallback onSessionExpired,
  }) {
    final dio = _createBaseDio(config);
    dio.interceptors.add(_MetadataAndTracingInterceptor(metadataProvider));

    final refreshCoordinator = _RefreshCoordinator(
      dio: dio,
      tokenStore: tokenStore,
      refreshSession: refreshSession,
      onSessionExpired: onSessionExpired,
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final skipAuthorization =
              options.extra[_RefreshCoordinator.skipAuthorizationKey] == true;
          final token = await tokenStore.readAccessToken();
          if (!skipAuthorization && token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: refreshCoordinator.onError,
      ),
    );

    return dio;
  }

  static Dio _createBaseDio(AppConfig config) {
    return Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: Duration(milliseconds: config.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: config.receiveTimeoutMs),
        sendTimeout: Duration(milliseconds: config.connectTimeoutMs),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}

class _MetadataAndTracingInterceptor extends Interceptor {
  _MetadataAndTracingInterceptor(this._metadataProvider);

  static int _requestSequence = 0;

  final RequestMetadataProvider _metadataProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final correlationId =
        (options.extra[_RefreshCoordinator.correlationIdKey] as String?) ??
        _nextCorrelationId();

    options.extra[_RefreshCoordinator.correlationIdKey] = correlationId;
    options.headers['X-Correlation-ID'] = correlationId;
    options.headers['User-Agent'] = _metadataProvider.userAgent;

    final fingerprint = _metadataProvider.fingerprint;
    if (fingerprint != null && fingerprint.isNotEmpty) {
      options.headers['X-Fingerprint'] = fingerprint;
    }

    handler.next(options);
  }

  String _nextCorrelationId() {
    _requestSequence += 1;
    return 'req-${DateTime.now().millisecondsSinceEpoch}-$_requestSequence';
  }
}

class _RefreshCoordinator {
  _RefreshCoordinator({
    required Dio dio,
    required AuthTokenStore tokenStore,
    required RefreshSessionCallback refreshSession,
    required SessionExpiredCallback onSessionExpired,
  }) : _dio = dio,
       _tokenStore = tokenStore,
       _refreshSession = refreshSession,
       _onSessionExpired = onSessionExpired;

  static const retryAttemptedKey = 'auth_retry_attempted';
  static const skipAuthRefreshKey = 'skip_auth_refresh';
  static const skipAuthorizationKey = 'skip_authorization';
  static const correlationIdKey = 'correlation_id';

  final Dio _dio;
  final AuthTokenStore _tokenStore;
  final RefreshSessionCallback _refreshSession;
  final SessionExpiredCallback _onSessionExpired;

  Future<void>? _refreshInFlight;

  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = error.response?.statusCode;
    final options = error.requestOptions;
    final shouldHandle401 =
        statusCode == 401 &&
        options.extra[retryAttemptedKey] != true &&
        options.extra[skipAuthRefreshKey] != true;

    if (!shouldHandle401) {
      handler.next(error);
      return;
    }

    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _onSessionExpired(
        AuthFailure(
          type: AuthFailureType.missingRefreshToken,
          statusCode: 401,
          message: 'Session expired. Please sign in again.',
          rawBody: error.response?.data,
        ),
      );
      handler.next(error);
      return;
    }

    final correlationId = options.extra[correlationIdKey] as String?;

    try {
      await _runSingleFlightRefresh(correlationId: correlationId);
      final response = await _retryRequest(options);
      handler.resolve(response);
    } on AuthFailure catch (failure) {
      if (failure.isTerminal ||
          failure.statusCode == 400 ||
          failure.statusCode == 401) {
        await _onSessionExpired(
          AuthFailure(
            type: AuthFailureType.sessionExpired,
            statusCode: failure.statusCode,
            message: failure.message,
            rawBody: failure.rawBody,
          ),
        );
      }
      handler.reject(_wrapFailure(options, failure));
    } catch (failure) {
      handler.reject(_wrapFailure(options, failure));
    }
  }

  Future<void> _runSingleFlightRefresh({String? correlationId}) {
    final refresh = _refreshInFlight;
    if (refresh != null) {
      return refresh;
    }

    final future = _refreshSession(correlationId: correlationId);
    _refreshInFlight = future.whenComplete(() => _refreshInFlight = null);
    return _refreshInFlight!;
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions options) {
    final retryExtra = Map<String, dynamic>.from(options.extra)
      ..[retryAttemptedKey] = true;

    return _dio.request<dynamic>(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      cancelToken: options.cancelToken,
      onReceiveProgress: options.onReceiveProgress,
      onSendProgress: options.onSendProgress,
      options: Options(
        method: options.method,
        headers: Map<String, dynamic>.from(options.headers),
        extra: retryExtra,
        responseType: options.responseType,
        contentType: options.contentType,
        validateStatus: options.validateStatus,
        receiveDataWhenStatusError: options.receiveDataWhenStatusError,
        followRedirects: options.followRedirects,
        sendTimeout: options.sendTimeout,
        receiveTimeout: options.receiveTimeout,
        listFormat: options.listFormat,
      ),
    );
  }

  DioException _wrapFailure(RequestOptions options, Object failure) {
    return DioException(
      requestOptions: options,
      error: failure,
      type: DioExceptionType.unknown,
    );
  }
}
