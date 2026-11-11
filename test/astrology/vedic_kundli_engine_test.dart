import 'package:flutter_test/flutter_test.dart';
import 'package:ved_rahasya/astrology/vedic_kundli_engine.dart';

void main() {
  group('VedicKundliEngine', () {
    const engine = VedicKundliEngine();

    test('calculates nine classical grahas, ascendant and a whole-sign chart', () {
      final chart = engine.calculate(
        birthUtc: DateTime.utc(1993, 10, 24, 20, 55),
        latitude: 24.03,
        longitudeEast: 84.07,
      );

      expect(chart.grahas, hasLength(9));
      expect(chart.lagnaLongitude, inInclusiveRange(0, 360));
      expect(chart.moon.rashi, isNotEmpty);
      expect(chart.grahasInHouse(1), isA<List<GrahaPosition>>());
      expect(chart.grahas.map((g) => g.name).toSet(), containsAll([
        'सूर्य', 'चंद्र', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'राहु', 'केतु',
      ]));
    });

    test('calculates navamsha signs within twelve rashis', () {
      final chart = engine.calculate(
        birthUtc: DateTime.utc(2000, 1, 1, 12),
        latitude: 0,
        longitudeEast: 0,
      );
      for (var longitude = 0.0; longitude < 360; longitude += 0.25) {
        expect(chart.navamshaSign(longitude), inInclusiveRange(0, 11));
      }
    });

    test('Vimshottari balance and antardasha periods are ordered', () {
      final timeline = VimshottariTimeline.fromMoonLongitude(
        10,
        DateTime.utc(2000, 1, 1),
      );
      expect(timeline.birthMahadasha, 'केतु');
      expect(timeline.balanceAtBirth.inDays, greaterThan(0));
      expect(timeline.mahadashas, isNotEmpty);
      final first = timeline.antardashas(timeline.mahadashas.first);
      expect(first, hasLength(9));
      expect(first.first.start, first.last.end.subtract(first.last.duration));
      expect(first.last.end, timeline.mahadashas.first.end);
    });
  });
}
