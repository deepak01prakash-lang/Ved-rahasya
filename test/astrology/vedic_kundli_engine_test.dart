import 'package:flutter_test/flutter_test.dart';
import 'package:ved_rahasya/astrology/vedic_kundli_engine.dart';
import 'package:ved_rahasya/astrology/graha_drishti.dart';
import 'package:ved_rahasya/astrology/kundli_interpretation.dart';

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

    test('all configured Parashari Vargas map into twelve signs', () {
      final chart = engine.calculate(
        birthUtc: DateTime.utc(2000, 1, 1, 12),
        latitude: 28.6,
        longitudeEast: 77.2,
      );
      const divisions = [1, 2, 3, 4, 7, 9, 10, 12, 16, 20, 24, 27, 30, 40, 45, 60];
      for (final division in divisions) {
        for (var longitude = 0.0; longitude < 360; longitude += 0.1) {
          expect(chart.divisionalSign(longitude, division), inInclusiveRange(0, 11));
        }
      }
    });

    test('D27 starts from the correct elemental signs', () {
      final chart = engine.calculate(
        birthUtc: DateTime.utc(2000, 1, 1, 12),
        latitude: 0,
        longitudeEast: 0,
      );
      expect(chart.divisionalSign(0.1, 27), 0); // Aries
      expect(chart.divisionalSign(30.1, 27), 3); // Cancer
      expect(chart.divisionalSign(60.1, 27), 6); // Libra
      expect(chart.divisionalSign(90.1, 27), 9); // Capricorn
    });

    test('graha dignity and aspect calculations return consistent chart data', () {
      final chart = engine.calculate(
        birthUtc: DateTime.utc(1993, 10, 24, 20, 55),
        latitude: 24.03,
        longitudeEast: 84.07,
      );
      final strengths = GrahaDrishti.strengths(chart);
      expect(strengths, hasLength(9));
      expect(strengths.map((s) => s.graha).toSet(), contains('सूर्य'));
      final aspects = GrahaDrishti.aspects(chart);
      expect(aspects.where((a) => a.fromGraha == 'मंगल'), hasLength(3));
      expect(aspects.where((a) => a.fromGraha == 'गुरु'), hasLength(3));
      expect(aspects.where((a) => a.fromGraha == 'शनि'), hasLength(3));
      expect(aspects.where((a) => a.fromGraha == 'सूर्य'), hasLength(1));
      expect(aspects.every((a) => a.toHouse >= 1 && a.toHouse <= 12), isTrue);
    });

    test('house lord analysis covers all twelve houses', () {
      final chart = engine.calculate(
        birthUtc: DateTime.utc(1993, 10, 24, 20, 55),
        latitude: 24.03,
        longitudeEast: 84.07,
      );
      final insights = KundliInterpretation.houseLords(chart);
      expect(insights, hasLength(12));
      expect(insights.map((item) => item.house), orderedEquals(List.generate(12, (i) => i + 1)));
      expect(insights.every((item) => item.placedHouse >= 1 && item.placedHouse <= 12), isTrue);
      final dashaInsight = KundliInterpretation.dashaLord(chart, 'गुरु');
      expect(dashaInsight.lord, 'गुरु');
      expect(dashaInsight.house, inInclusiveRange(1, 12));
      expect(dashaInsight.sign, isNotEmpty);
      expect(dashaInsight.ruledHouses, isNotEmpty);
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
      expect(first.first.start, timeline.mahadashas.first.start);
      expect(first.last.end, timeline.mahadashas.first.end);
    });
  });
}
