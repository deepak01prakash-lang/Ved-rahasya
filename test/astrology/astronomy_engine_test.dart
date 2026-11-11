import 'package:flutter_test/flutter_test.dart';
import 'package:ved_rahasya/astrology/astronomy_engine.dart';

void main() {
  group('AstronomyEngine', () {
    const engine = AstronomyEngine();

    test('calculates plausible tropical positions at J2000', () {
      final snapshot = engine.positionsAtUtc(DateTime.utc(2000, 1, 1, 12));

      // Meeus J2000 reference neighbourhood; broad tolerances avoid implying
      // a more precise validation than this smoke test provides.
      expect(snapshot.sunTropicalLongitude, inInclusiveRange(279.0, 282.0));
      expect(snapshot.moonTropicalLongitude, inInclusiveRange(220.0, 226.0));
      expect(snapshot.julianDayUt, closeTo(2451545.0, 0.000001));
    });

    test('normalizes lunar elongation and illumination', () {
      final snapshot = engine.positionsAtUtc(DateTime.utc(2026, 11, 11));
      expect(snapshot.elongation, inInclusiveRange(0.0, 360.0));
      expect(snapshot.lunarIlluminatedFraction, inInclusiveRange(0.0, 1.0));
    });
  });
}
