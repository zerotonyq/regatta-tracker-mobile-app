import 'api_exception.dart';

enum AuthFailureType {
  unauthorized,
  invalidCredentials,
  sessionExpired,
  missingRefreshToken,
}

class AuthFailure extends ApiException {
  AuthFailure({
    required this.type,
    required super.statusCode,
    required super.message,
    super.rawBody,
  });

  final AuthFailureType type;

  bool get isTerminal =>
      type == AuthFailureType.sessionExpired ||
      type == AuthFailureType.missingRefreshToken;
}
