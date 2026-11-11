import 'dart:math' as math;

import 'astronomy_engine.dart';

class DailyPanchang {
  const DailyPanchang({
    required this.localDate,
    required this.sunriseLocal,
    required this.sunsetLocal,
    required this.tithi,
    required this.tithiPaksha,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.vara,
    required this.sunriseAvailable,
  });

  final DateTime localDate;
  final DateTime? sunriseLocal;
  final DateTime? sunsetLocal;
  final String tithi;
  final String tithiPaksha;
  final String nakshatra;
  final String yoga;
  final String karana;
  final String vara;
  final bool sunriseAvailable;
}

class PanchangEngine {
  const PanchangEngine();

  static const _tithis = <String>[
    'प्रतिपदा', 'द्वितीया', 'तृतीया', 'चतुर्थी', 'पञ्चमी',
    'षष्ठी', 'सप्तमी', 'अष्टमी', 'नवमी', 'दशमी',
    'एकादशी', 'द्वादशी', 'त्रयोदशी', 'चतुर्दशी', 'पूर्णिमा',
  ];
  static const _nakshatras = VedicLunarPosition.nakshatras;
  static const _yogas = <String>[
    'विष्कम्भ', 'प्रीति', 'आयुष्मान', 'सौभाग्य', 'शोभन', 'अतिगण्ड',
    'सुकर्मा', 'धृति', 'शूल', 'गण्ड', 'वृद्धि', 'ध्रुव', 'व्याघात',
    'हर्षण', 'वज्र', 'सिद्धि', 'व्यतीपात', 'वरीयान', 'परिघ', 'शिव',
    'सिद्ध', 'साध्य', 'शुभ', 'शुक्ल', 'ब्रह्म', 'इन्द्र', 'वैधृति',
  ];
  static const _movableKaranas = <String>[
    'बव', 'बालव', 'कौलव', 'तैतिल', 'गर', 'वणिज', 'विष्टि (भद्रा)',
  ];
  static const _fixedKaranas = <String>[
    'किंस्तुघ्न', 'शकुनि', 'चतुष्पद', 'नाग',
  ];
  static const _varas = <String>[
    'रविवार', 'सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार',
  ];

  DailyPanchang calculate({
    required DateTime localDate,
    required double latitude,
    required double longitudeEast,
    required Duration utcOffset,
  }) {
    if (latitude < -66 || latitude > 66) {
      throw ArgumentError.value(latitude, 'latitude',
          'Panchang sunrise calculation is supported between 66°S and 66°N');
    }
    if (longitudeEast < -180 || longitudeEast > 180) {
      throw ArgumentError.value(longitudeEast, 'longitudeEast');
    }

    final date = DateTime(localDate.year, localDate.month, localDate.day);
    final sunriseUtc = _solarEventUtc(date, latitude, longitudeEast, sunrise: true);
    final sunsetUtc = _solarEventUtc(date, latitude, longitudeEast, sunrise: false);
    if (sunriseUtc == null || sunsetUtc == null) {
      throw StateError('इस अक्षांश पर इस दिन सूर्योदय/सूर्यास्त का समय उपलब्ध नहीं है।');
    }

    final sunriseLocal = sunriseUtc.add(utcOffset);
    final sunsetLocal = sunsetUtc.add(utcOffset);
    final snapshot = const AstronomyEngine().positionsAtUtc(sunriseUtc);
    final moon = VedicLunarPosition.fromTropicalMoon(
      snapshot.moonTropicalLongitude, sunriseUtc);
    final sunSidereal = LahiriAyanamsha.siderealLongitude(
      snapshot.sunTropicalLongitude, sunriseUtc);
    final elongation = snapshot.elongation;
    final tithiIndex = (elongation / 12).floor().clamp(0, 29);
    final tithiNumber = (tithiIndex % 15) + 1;
    final paksha = tithiIndex < 15 ? 'शुक्ल पक्ष' : 'कृष्ण पक्ष';
    final tithiName = tithiIndex % 15 == 14
        ? (tithiIndex < 15 ? 'पूर्णिमा' : 'अमावस्या')
        : _tithis[tithiNumber - 1];
    final yogaIndex = (((sunSidereal + moon.siderealLongitude) % 360) /
            (360 / 27)).floor().clamp(0, 26);
    final karanaIndex = (elongation / 6).floor().clamp(0, 59);
    final karana = switch (karanaIndex) {
      0 => _fixedKaranas[0],
      >= 57 => _fixedKaranas[karanaIndex - 56],
      _ => _movableKaranas[(karanaIndex - 1) % 7],
    };

    return DailyPanchang(
      localDate: date,
      sunriseLocal: sunriseLocal,
      sunsetLocal: sunsetLocal,
      tithi: tithiName,
      tithiPaksha: paksha,
      nakshatra: _nakshatras[moon.nakshatraIndex],
      yoga: _yogas[yogaIndex],
      karana: karana,
      vara: _varas[date.weekday % 7],
      sunriseAvailable: true,
    );
  }

  DateTime? _solarEventUtc(
    DateTime date,
    double latitude,
    double longitude,
    {required bool sunrise}
  ) {
    final day = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final gamma = 2 * math.pi / 365 * (day - 1);
    final equationMinutes = 229.18 * (0.000075 +
        0.001868 * math.cos(gamma) -
        0.032077 * math.sin(gamma) -
        0.014615 * math.cos(2 * gamma) -
        0.040849 * math.sin(2 * gamma));
    final declination = 0.006918 -
        0.399912 * math.cos(gamma) +
        0.070257 * math.sin(gamma) -
        0.006758 * math.cos(2 * gamma) +
        0.000907 * math.sin(2 * gamma) -
        0.002697 * math.cos(3 * gamma) +
        0.00148 * math.sin(3 * gamma);
    final lat = latitude * math.pi / 180;
    const zenith = 90.833 * math.pi / 180;
    final cosHourAngle = (math.cos(zenith) /
            (math.cos(lat) * math.cos(declination))) -
        math.tan(lat) * math.tan(declination);
    if (cosHourAngle < -1 || cosHourAngle > 1) return null;
    final hourAngle = math.acos(cosHourAngle) * 180 / math.pi;
    final minutesUtc = 720 - 4 * longitude - equationMinutes +
        (sunrise ? -4 * hourAngle : 4 * hourAngle);
    return DateTime.utc(date.year, date.month, date.day)
        .add(Duration(seconds: (minutesUtc * 60).round()));
  }
}
