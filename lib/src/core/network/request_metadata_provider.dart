class RequestMetadataProvider {
  const RequestMetadataProvider({
    required this.userAgent,
    required this.fingerprint,
  });

  final String userAgent;
  final String? fingerprint;
}
