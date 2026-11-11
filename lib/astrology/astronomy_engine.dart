import 'dart:math' as math;

import 'package:astronomia/astronomia.dart';
import 'package:astronomia/moonposition.dart' as moon;
import 'package:astronomia/solar.dart' as solar;

/// Low-level astronomical positions used as the foundation for the Vedic
/// calculation engine.
///
/// IMPORTANT: these are apparent tropical ecliptic longitudes. They are not
/// yet Lahiri-sidereal positions and must not be presented as a Vedic Rashi,
/// Nakshatra, Lagna, or Panchanga result until ayanamsa, observer/time-zone,
/// and sunrise-boundary rules have been applied and validated.
class AstronomicalSnapshot {
  const AstronomicalSnapshot({
    required this.julianDayUt,
    required this.sunTropicalLongitude,
    required this.moonTropicalLongitude,
  });

  final double julianDayUt;
  final double sunTropicalLongitude;
  final double moonTropicalLongitude;

  double get elongation =>
      _normalizeDegrees(moonTropicalLongitude - sunTropicalLongitude);

  double get lunarIlluminatedFraction =>
      (1 - math.cos(elongation * math.pi / 180)) / 2;

  static double _normalizeDegrees(double value) =>
      (value % 360 + 360) % 360;
}

class AstronomyEngine {
  const AstronomyEngine();

  /// Calculates geocentric apparent tropical Sun and Moon longitudes.
  ///
  /// [utc] must represent the actual UTC instant, not an unconverted local
  /// birth-clock time. Geographic coordinates are intentionally not accepted
  /// here because these geocentric longitudes do not depend on the observer.
  AstronomicalSnapshot positionsAtUtc(DateTime utc) {
    final instant = utc.toUtc();
    final dayFraction = (instant.hour +
            instant.minute / 60 +
            instant.second / 3600 +
            instant.millisecond / 3600000 +
            instant.microsecond / 3600000000) /
        24;
    final jd = calendarGregorianToJD(
      instant.year,
      instant.month,
      instant.day + dayFraction,
    );

    final sunLongitude = toDeg(solar.apparentLongitude(j2000Century(jd)));
    final moonPosition = moon.position(jd);

    return AstronomicalSnapshot(
      julianDayUt: jd,
      sunTropicalLongitude: (sunLongitude % 360 + 360) % 360,
      moonTropicalLongitude: (toDeg(moonPosition.lon) % 360 + 360) % 360,
    );
  }
}


/// Lahiri/Chitrapaksha mean ayanamsha reference implementation.
///
/// Uses a J2000 Lahiri reference value and a polynomial
/// precession approximation. It is a mean ayanamsha (nutation is not added),
/// so boundary cases must be cross-checked against a validated ephemeris
/// before being used for production kundli or Panchanga claims.
class LahiriAyanamsha {
  const LahiriAyanamsha._();

  static const double _epochJd = 2451545.0; // J2000.0, 2000-01-01 12:00 TT
  static const double _epochArcSeconds = 23 * 3600 + 51 * 60 + 25.532;

  static double meanDegreesAtUtc(DateTime utc) {
    final instant = utc.toUtc();
    final dayFraction = (instant.hour +
            instant.minute / 60 +
            instant.second / 3600 +
            instant.millisecond / 3600000 +
            instant.microsecond / 3600000000) /
        24;
    final jd = calendarGregorianToJD(
      instant.year,
      instant.month,
      instant.day + dayFraction,
    );
    final centuries = (jd - _epochJd) / 36525.0;
    final arcSeconds = _epochArcSeconds +
        5029.0966 * centuries +
        1.11161 * centuries * centuries;
    return arcSeconds / 3600.0;
  }

  static double siderealLongitude(double tropicalLongitude, DateTime utc) {
    final value = tropicalLongitude - meanDegreesAtUtc(utc);
    final normalized = (value % 360 + 360) % 360;
    // Avoid representing a value infinitesimally below 0° as 360° due
    // to floating-point rounding; the two values are the same boundary.
    if (normalized < 1e-7 || normalized > 360 - 1e-7) {
      return 0.0;
    }
    return normalized;
  }
}

class VedicLunarPosition {
  const VedicLunarPosition({
    required this.siderealLongitude,
    required this.rashiIndex,
    required this.nakshatraIndex,
    required this.nakshatraPada,
  });

  final double siderealLongitude;
  final int rashiIndex;
  final int nakshatraIndex;
  final int nakshatraPada;

  static const rashis = [
    'मेष', 'वृषभ', 'मिथुन', 'कर्क', 'सिंह', 'कन्या',
    'तुला', 'वृश्चिक', 'धनु', 'मकर', 'कुंभ', 'मीन',
  ];

  static const nakshatras = [
    'अश्विनी', 'भरणी', 'कृत्तिका', 'रोहिणी', 'मृगशिरा', 'आर्द्रा',
    'पुनर्वसु', 'पुष्य', 'आश्लेषा', 'मघा', 'पूर्वा फाल्गुनी',
    'उत्तरा फाल्गुनी', 'हस्त', 'चित्रा', 'स्वाती', 'विशाखा',
    'अनुराधा', 'ज्येष्ठा', 'मूल', 'पूर्वाषाढ़ा', 'उत्तराषाढ़ा',
    'श्रवण', 'धनिष्ठा', 'शतभिषा', 'पूर्वाभाद्रपद', 'उत्तराभाद्रपद',
    'रेवती',
  ];

  factory VedicLunarPosition.fromTropicalMoon(
    double tropicalLongitude,
    DateTime utc,
  ) {
    final longitude = LahiriAyanamsha.siderealLongitude(
      tropicalLongitude,
      utc,
    );
    const nakshatraWidth = 360.0 / 27.0;
    const padaWidth = nakshatraWidth / 4.0;
    return VedicLunarPosition(
      siderealLongitude: longitude,
      rashiIndex: (longitude / 30).floor(),
      nakshatraIndex: (longitude / nakshatraWidth).floor(),
      nakshatraPada: ((longitude % nakshatraWidth) / padaWidth).floor() + 1,
    );
  }

  String get rashi => rashis[rashiIndex];
  String get nakshatra => nakshatras[nakshatraIndex];
}
