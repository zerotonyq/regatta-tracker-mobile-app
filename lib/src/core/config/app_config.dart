import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig({
    required this.baseUrl,
    required this.userAgent,
    required this.connectTimeoutMs,
    required this.receiveTimeoutMs,
    required this.useMockApi,
    this.fingerprint,
  });

  final String baseUrl;
  final String userAgent;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;
  final bool useMockApi;
  final String? fingerprint;

  factory AppConfig.fromEnvironment() {
    final configuredBaseUrl = const String.fromEnvironment('API_BASE_URL');
    const configuredFingerprint = String.fromEnvironment('API_FINGERPRINT');
    return AppConfig(
      baseUrl: configuredBaseUrl.isNotEmpty
          ? configuredBaseUrl
          : _defaultBaseUrlForPlatform(),
      userAgent: const String.fromEnvironment(
        'API_USER_AGENT',
        defaultValue: 'vkr-regatta-mobile/1.0.0',
      ),
      connectTimeoutMs: int.fromEnvironment(
        'API_CONNECT_TIMEOUT_MS',
        defaultValue: 15000,
      ),
      receiveTimeoutMs: int.fromEnvironment(
        'API_RECEIVE_TIMEOUT_MS',
        defaultValue: 15000,
      ),
      useMockApi: false,
      fingerprint: configuredFingerprint.isNotEmpty
          ? configuredFingerprint
          : _defaultFingerprintForPlatform(),
    );
  }

  static String _defaultBaseUrlForPlatform() {
    if (kIsWeb) {
      return 'http://localhost';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://localhost';
      case TargetPlatform.fuchsia:
        return 'http://localhost';
    }
  }

  static String _defaultFingerprintForPlatform() {
    if (kIsWeb) {
      return 'vkr-regatta-web-dev';
    }

    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
    return 'vkr-regatta-$platform-dev';
  }
}
