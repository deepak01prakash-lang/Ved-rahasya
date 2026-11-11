import 'package:flutter_test/flutter_test.dart';
import 'package:ved_rahasya/astrology/astronomy_engine.dart';

void main() {
  group('Lahiri sidereal foundation', () {
    test('returns the configured J2000 Lahiri reference value', () {
      final value = LahiriAyanamsha.meanDegreesAtUtc(
        DateTime.utc(2000, 1, 1, 12),
      );
      expect(value, closeTo(23.8570922, 0.00001));
    });

    test('normalizes sidereal longitude into 0 to 360 degrees', () {
      final value = LahiriAyanamsha.siderealLongitude(
        10,
        DateTime.utc(2000, 1, 1, 12),
      );
      expect(value, closeTo(346.1429078, 0.00001));
      expect(value, greaterThanOrEqualTo(0));
      expect(value, lessThan(360));
    });

    test('maps a sidereal lunar longitude to rashi and nakshatra', () {
      final moon = VedicLunarPosition.fromTropicalMoon(
        23.8570922,
        DateTime.utc(2000, 1, 1, 12),
      );
      expect(moon.siderealLongitude, closeTo(0, 0.00001));
      expect(moon.rashi, 'मेष');
      expect(moon.nakshatra, 'अश्विनी');
      expect(moon.nakshatraPada, 1);
    });
  });
}
