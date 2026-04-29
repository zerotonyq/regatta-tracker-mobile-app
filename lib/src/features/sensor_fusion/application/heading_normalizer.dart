import 'dart:math' as math;

class HeadingNormalizer {
  const HeadingNormalizer();

  double normalizeDegrees(double degrees) {
    final normalized = degrees % 360.0;
    return normalized < 0 ? normalized + 360.0 : normalized;
  }

  double radiansToNormalizedDegrees(double radians) {
    return normalizeDegrees(radians * 180.0 / math.pi);
  }
}
