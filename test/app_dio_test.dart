import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/core/config/app_config.dart';
import 'package:vkr_regatta/src/core/network/app_dio.dart';
import 'package:vkr_regatta/src/core/network/auth_token_store.dart';
import 'package:vkr_regatta/src/core/network/request_metadata_provider.dart';

void main() {
  test(
    'AppDio adds metadata headers and performs a single refresh for parallel 401s',
    () async {
      final tokenStore = InMemoryAuthTokenStore();
      await tokenStore.writeTokens(
        accessToken: 'stale-access-token',
        refreshToken: 'refresh-token',
      );

      final adapter = _FakeHttpClientAdapter();
      var refreshCount = 0;

      final dio = AppDio.createProtectedClient(
        config: AppConfig(
          baseUrl: 'http://localhost',
          userAgent: 'vkr-regatta-mobile/1.0.0',
          connectTimeoutMs: 15000,
          receiveTimeoutMs: 15000,
          useMockApi: false,
          fingerprint: 'device-fingerprint',
        ),
        tokenStore: tokenStore,
        metadataProvider: const RequestMetadataProvider(
          userAgent: 'vkr-regatta-mobile/1.0.0',
          fingerprint: 'device-fingerprint',
        ),
        refreshSession: ({String? correlationId}) async {
          refreshCount += 1;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          await tokenStore.writeTokens(
            accessToken: 'fresh-access-token',
            refreshToken: 'fresh-refresh-token',
          );
        },
        onSessionExpired: (failure) async {},
      );
      dio.httpClientAdapter = adapter;

      final responses = await Future.wait([
        dio.get<Map<String, dynamic>>('/protected'),
        dio.get<Map<String, dynamic>>('/protected'),
      ]);

      expect(refreshCount, 1);
      expect(responses, hasLength(2));
      expect(adapter.userAgents, everyElement('vkr-regatta-mobile/1.0.0'));
      expect(adapter.fingerprints, everyElement('device-fingerprint'));
      expect(adapter.correlationIds.every((value) => value.isNotEmpty), isTrue);
    },
  );
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  final List<String> userAgents = <String>[];
  final List<String> fingerprints = <String>[];
  final List<String> correlationIds = <String>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    userAgents.add(options.headers['User-Agent'] as String? ?? '');
    fingerprints.add(options.headers['X-Fingerprint'] as String? ?? '');
    correlationIds.add(options.headers['X-Correlation-ID'] as String? ?? '');

    final authHeader = options.headers['Authorization'] as String?;
    final headers = <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    };

    if (authHeader == 'Bearer stale-access-token') {
      return ResponseBody.fromString(
        jsonEncode(<String, String>{'message': 'Unauthorized request.'}),
        401,
        headers: headers,
      );
    }

    return ResponseBody.fromString(
      jsonEncode(<String, String>{'status': 'OK'}),
      200,
      headers: headers,
    );
  }
}
