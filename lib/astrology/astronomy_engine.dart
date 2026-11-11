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
