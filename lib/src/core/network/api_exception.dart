class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message, this.rawBody});

  final int? statusCode;
  final String message;
  final Object? rawBody;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}
