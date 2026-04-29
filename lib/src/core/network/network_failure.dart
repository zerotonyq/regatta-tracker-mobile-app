import 'api_exception.dart';

enum NetworkFailureType { offline, timeout, server, unknown }

class NetworkFailure extends ApiException {
  NetworkFailure({
    required this.type,
    required super.statusCode,
    required super.message,
    super.rawBody,
  });

  final NetworkFailureType type;

  bool get isRetryable =>
      type == NetworkFailureType.offline || type == NetworkFailureType.timeout;
}
