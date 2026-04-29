class TrackingSessionFailure implements Exception {
  TrackingSessionFailure(this.message);

  final String message;

  @override
  String toString() => 'TrackingSessionFailure($message)';
}
