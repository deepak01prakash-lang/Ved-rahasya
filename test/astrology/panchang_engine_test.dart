import 'package:flutter_test/flutter_test.dart';
import 'package:ved_rahasya/astrology/panchang_engine.dart';

void main() {
  group('PanchangEngine', () {
    const engine = PanchangEngine();

    test('calculates sunrise and sunset near a published Delhi equinox reference', () {
      final result = engine.calculate(
        localDate: DateTime(2024, 3, 20),
        latitude: 28.6139,
        longitudeEast: 77.2090,
        utcOffset: const Duration(hours: 5, minutes: 30),
      );

      // NOAA-style solar event approximation: Delhi sunrise ~06:25,
      // sunset ~18:33 local time on the March equinox.
      expect(result.sunriseLocal!.hour, 6);
      expect(result.sunriseLocal!.minute, inInclusiveRange(22, 28));
      expect(result.sunsetLocal!.hour, 18);
      expect(result.sunsetLocal!.minute, inInclusiveRange(29, 36));
    });

    test('returns all five sunrise Panchang limbs and weekday', () {
      final result = engine.calculate(
        localDate: DateTime(2026, 11, 11),
        latitude: 24.03,
        longitudeEast: 84.07,
        utcOffset: const Duration(hours: 5, minutes: 30),
      );

      expect(result.tithi, isNotEmpty);
      expect(result.tithiPaksha, anyOf('शुक्ल पक्ष', 'कृष्ण पक्ष'));
      expect(result.nakshatra, isNotEmpty);
      expect(result.yoga, isNotEmpty);
      expect(result.karana, isNotEmpty);
      expect(result.vara, 'बुधवार');
      expect(result.sunriseLocal, isNotNull);
      expect(result.sunsetLocal, isNotNull);
    });

    test('rejects polar latitudes where this sunrise model is unsupported', () {
      expect(
        () => engine.calculate(
          localDate: DateTime(2026, 6, 21),
          latitude: 70,
          longitudeEast: 20,
          utcOffset: Duration.zero,
        ),
        throwsArgumentError,
      );
    });
  });
}
