import 'astronomy_engine.dart';
import 'vedic_kundli_engine.dart';

class GrahaAspect {
  const GrahaAspect({
    required this.fromGraha,
    required this.toHouse,
    required this.toRashi,
    required this.aspectName,
    required this.occupants,
  });

  final String fromGraha;
  final int toHouse;
  final String toRashi;
  final String aspectName;
  final List<String> occupants;
}

class GrahaStrength {
  const GrahaStrength({
    required this.graha,
    required this.dignity,
    required this.isExalted,
    required this.isDebilitated,
    required this.isOwnSign,
    required this.sunDistance,
    required this.isCombust,
  });

  final String graha;
  final String dignity;
  final bool isExalted;
  final bool isDebilitated;
  final bool isOwnSign;
  final double sunDistance;
  final bool isCombust;
}

class GrahaDrishti {
  static const _dignities = <String, ({int exalt, int debil, Set<int> own})>{
    'सूर्य': (exalt: 0, debil: 6, own: {4}),
    'चंद्र': (exalt: 1, debil: 7, own: {3}),
    'मंगल': (exalt: 9, debil: 3, own: {0, 7}),
    'बुध': (exalt: 5, debil: 11, own: {2, 5}),
    'गुरु': (exalt: 3, debil: 9, own: {8, 11}),
    'शुक्र': (exalt: 11, debil: 5, own: {1, 6}),
    'शनि': (exalt: 6, debil: 0, own: {9, 10}),
  };

  static const _combustionOrbs = <String, double>{
    'चंद्र': 12,
    'मंगल': 17,
    'बुध': 14,
    'गुरु': 11,
    'शुक्र': 10,
    'शनि': 15,
  };

  static double angularDistance(double a, double b) {
    final difference = (a - b).abs() % 360;
    return difference > 180 ? 360 - difference : difference;
  }

  static List<GrahaStrength> strengths(VedicKundli chart) {
    final sun = chart.grahas.firstWhere((g) => g.name == 'सूर्य');
    return chart.grahas.map((g) {
      final rules = _dignities[g.name];
      final exalted = rules != null && g.rashiIndex == rules.exalt;
      final debilitated = rules != null && g.rashiIndex == rules.debil;
      final own = rules?.own.contains(g.rashiIndex) ?? false;
      final distance = angularDistance(g.longitude, sun.longitude);
      final orb = _combustionOrbs[g.name];
      final combust = g.name != 'सूर्य' && orb != null && distance <= orb;
      final dignity = exalted
          ? 'उच्च राशि'
          : debilitated
              ? 'नीच राशि'
              : own
                  ? 'स्वराशि'
                  : 'अन्य राशि';
      return GrahaStrength(
        graha: g.name,
        dignity: dignity,
        isExalted: exalted,
        isDebilitated: debilitated,
        isOwnSign: own,
        sunDistance: distance,
        isCombust: combust,
      );
    }).toList(growable: false);
  }

  static List<GrahaAspect> aspects(VedicKundli chart) {
    const special = <String, Map<int, String>>{
      'मंगल': {4: 'चतुर्थ', 8: 'अष्टम'},
      'गुरु': {5: 'पंचम', 9: 'नवम'},
      'शनि': {3: 'तृतीय', 10: 'दशम'},
    };
    final result = <GrahaAspect>[];
    for (final graha in chart.grahas) {
      final offsets = <int, String>{7: 'सप्तम'};
      offsets.addAll(special[graha.name] ?? const {});
      for (final entry in offsets.entries) {
        final targetSign = (graha.rashiIndex + entry.key - 1) % 12;
        final house = (targetSign - chart.lagnaRashiIndex + 12) % 12 + 1;
        final occupants = chart.grahas
            .where((other) => other.rashiIndex == targetSign && other.name != graha.name)
            .map((other) => other.name)
            .toList();
        result.add(GrahaAspect(
          fromGraha: graha.name,
          toHouse: house,
          toRashi: VedicLunarPosition.rashis[targetSign],
          aspectName: entry.value,
          occupants: occupants,
        ));
      }
    }
    return result;
  }
}
