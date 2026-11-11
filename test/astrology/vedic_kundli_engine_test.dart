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

    test('J2000 tropical longitudes agree with an independent ephemeris reference', () {
      final instant = DateTime.utc(2000, 1, 1, 12);
      final chart = engine.calculate(
        birthUtc: instant,
        latitude: 0,
        longitudeEast: 0,
      );
      const ayanamshaAtJ2000 = 23.8570922;
      final references = <String, double>{
        'सूर्य': 280.3686,
        'चंद्र': 223.3239,
        'मंगल': 327.9639,
        'बुध': 271.8889,
        'गुरु': 25.2542,
        'शुक्र': 241.5653,
        'शनि': 40.3961,
      };
      for (final entry in references.entries) {
        final actual = (chart.grahas
                    .firstWhere((graha) => graha.name == entry.key)
                    .longitude +
                ayanamshaAtJ2000) %
            360;
        final delta = ((actual - entry.value + 540) % 360) - 180;
        expect(delta.abs(), lessThan(0.5), reason: entry.key);
      }
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

    test('D3 follows odd/even sign Drekkana starting rules', () {
      final chart = engine.calculate(
        birthUtc: DateTime.utc(2000, 1, 1, 12),
        latitude: 0,
        longitudeEast: 0,
      );
      // Odd signs: same, 5th, 9th. Even signs: 9th, 5th, same.
      expect(chart.divisionalSign(0.1, 3), 0); // Aries -> Aries
      expect(chart.divisionalSign(10.1, 3), 4); // Aries -> Leo
      expect(chart.divisionalSign(20.1, 3), 8); // Aries -> Sagittarius
      expect(chart.divisionalSign(30.1, 3), 9); // Taurus -> Capricorn
      expect(chart.divisionalSign(40.1, 3), 1); // Taurus -> Taurus
      expect(chart.divisionalSign(50.1, 3), 5); // Taurus -> Virgo
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
      final indicators = KundliInterpretation.indicators(chart);
      expect(indicators.map((item) => item.name), containsAll([
        'रुचक महापुरुष योग',
        'भद्र महापुरुष योग',
        'हंस महापुरुष योग',
        'मालव्य महापुरुष योग',
        'शश महापुरुष योग',
      ]));
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
      // Birth Mahadasha is Ketu; after the first nine-period sequence,
      // the next complete cycle must restart with Ketu, not Venus.
      expect(timeline.mahadashas[9].lord, 'केतु');
      final first = timeline.antardashas(timeline.mahadashas.first);
      expect(first, hasLength(9));
      expect(first.first.start, timeline.mahadashas.first.start);
      expect(first.last.end, timeline.mahadashas.first.end);
      final subPeriod = timeline.pratyantardashas(first.first);
      expect(subPeriod, hasLength(9));
      expect(subPeriod.first.start, first.first.start);
      expect(subPeriod.last.end, first.first.end);
    });
  });
}
