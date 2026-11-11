import 'dart:math' as math;

import 'package:astronomia/astronomia.dart';
import 'package:astronomia/elliptic.dart' as elliptic;
import 'package:astronomia/planetposition.dart' as planets;
import 'package:astronomia/moonposition.dart' as lunar;
import 'package:astronomia/sidereal.dart' as sidereal;

import 'astronomy_engine.dart';

class GrahaPosition {
  const GrahaPosition({
    required this.name,
    required this.longitude,
    required this.latitude,
    required this.isRetrograde,
  });

  final String name;
  final double longitude;
  final double latitude;
  final bool isRetrograde;

  int get rashiIndex => (longitude / 30).floor() % 12;
  double get degreesInRashi => longitude % 30;
}

class VedicKundli {
  const VedicKundli({
    required this.julianDayUt,
    required this.lagnaLongitude,
    required this.grahas,
    required this.moon,
    required this.vimshottari,
  });

  final double julianDayUt;
  final double lagnaLongitude;
  final List<GrahaPosition> grahas;
  final VedicLunarPosition moon;
  final VimshottariTimeline vimshottari;

  int get lagnaRashiIndex => (lagnaLongitude / 30).floor() % 12;
  List<GrahaPosition> grahasInHouse(int house) {
    final rashi = (lagnaRashiIndex + house - 1) % 12;
    return grahas.where((g) => g.rashiIndex == rashi).toList();
  }

  /// Traditional Parashari divisional sign mapping for commonly used Vargas.
  /// D30 uses the unequal Trimsamsa spans; other supported Vargas use equal parts.
  int divisionalSign(double longitude, int division) {
    if (division == 9) return navamshaSign(longitude);
    if (![2, 3, 4, 7, 10, 12, 16, 20, 24, 27, 30, 40, 45, 60].contains(division)) {
      if (division == 1) return (longitude / 30).floor() % 12;
      throw ArgumentError.value(division, 'division', 'Unsupported Varga');
    }
    final sign = (longitude / 30).floor() % 12;
    final degree = longitude % 30;
    if (division == 2) {
      final firstHalf = degree < 15;
      if (sign.isEven) return firstHalf ? 4 : 3;
      return firstHalf ? 3 : 4;
    }
    if (division == 30) {
      if (sign.isEven) {
        if (degree < 5) return 0;
        if (degree < 10) return 10;
        if (degree < 18) return 8;
        if (degree < 25) return 2;
        return 6;
      }
      if (degree < 5) return 1;
      if (degree < 12) return 5;
      if (degree < 20) return 11;
      if (degree < 25) return 9;
      return 7;
    }

    final part = (degree / (30 / division)).floor().clamp(0, division - 1).toInt();
    int start;
    switch (division) {
      case 3:
        start = sign;
        break;
      case 4:
        start = sign;
        break;
      case 7:
        start = sign.isEven ? sign : (sign + 6) % 12;
        break;
      case 10:
        start = sign.isEven ? sign : (sign + 8) % 12;
        break;
      case 12:
        start = sign;
        break;
      case 16:
        start = [0, 4, 8][sign % 3];
        break;
      case 20:
        start = [0, 8, 4][sign % 3];
        break;
      case 24:
        start = sign.isEven ? 4 : 3;
        break;
      case 27:
        start = [0, 3, 6][sign % 3];
        break;
      case 40:
        start = sign.isEven ? 0 : 6;
        break;
      case 45:
        start = [0, 4, 8][sign % 3];
        break;
      case 60:
        start = sign.isEven ? 0 : 6;
        break;
      default:
        throw ArgumentError.value(division, 'division');
    }
    final step = switch (division) {
      3 => 4,
      4 => 3,
      _ => 1,
    };
    return (start + part * step) % 12;
  }

  /// Navamsha (D9) sign index using the movable/fixed/dual sign rule.
  int navamshaSign(double siderealLongitude) {
    final sign = (siderealLongitude / 30).floor() % 12;
    final part = ((siderealLongitude % 30) / (30 / 9)).floor().clamp(0, 8).toInt();
    final start = switch (sign % 3) {
      0 => sign, // movable signs begin from themselves
      1 => (sign + 8) % 12, // fixed signs begin from the 9th
      _ => (sign + 4) % 12, // dual signs begin from the 5th
    };
    return (start + part) % 12;
  }
}

class VedicKundliEngine {
  const VedicKundliEngine();

  static const _grahaNames = <String>[
    'सूर्य', 'चंद्र', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'राहु', 'केतु',
  ];

  VedicKundli calculate({
    required DateTime birthUtc,
    required double latitude,
    required double longitudeEast,
  }) {
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError.value(latitude, 'latitude', 'Must be -90 to 90');
    }
    if (longitudeEast < -180 || longitudeEast > 180) {
      throw ArgumentError.value(longitudeEast, 'longitudeEast', 'Must be -180 to 180');
    }

    final snapshot = const AstronomyEngine().positionsAtUtc(birthUtc);
    final jd = snapshot.julianDayUt;
    final moon = VedicLunarPosition.fromTropicalMoon(
      snapshot.moonTropicalLongitude,
      birthUtc,
    );

    final tropical = <String, ({double lon, double lat})>{
      'सूर्य': (lon: snapshot.sunTropicalLongitude, lat: 0),
      'चंद्र': (
        lon: snapshot.moonTropicalLongitude,
        lat: toDeg(lunar.position(jd).lat),
      ),
    };

    final earth = planets.Planet(planets.planetEarth);
    final bodyIndices = <String, int>{
      'मंगल': planets.planetMars,
      'बुध': planets.planetMercury,
      'गुरु': planets.planetJupiter,
      'शुक्र': planets.planetVenus,
      'शनि': planets.planetSaturn,
    };
    final eps = meanObliquity(jd) + nutation(jd).dEps;
    for (final entry in bodyIndices.entries) {
      final body = planets.Planet(entry.value);
      final eq = elliptic.position(body, earth, jd);
      final ecl = eqToEcl(eq.ra, eq.dec, math.sin(eps), math.cos(eps));
      tropical[entry.key] = (lon: toDeg(ecl.lon), lat: toDeg(ecl.lat));
    }

    final t = (jd - 2451545.0) / 36525.0;
    final rahuTropical = _normalize(125.04452 - 1934.136261 * t +
        0.0020708 * t * t + t * t * t / 450000);
    tropical['राहु'] = (lon: rahuTropical, lat: 0);
    tropical['केतु'] = (lon: _normalize(rahuTropical + 180), lat: 0);

    final positions = <GrahaPosition>[];
    for (final name in _grahaNames) {
      final p = tropical[name]!;
      final longitudeSidereal = LahiriAyanamsha.siderealLongitude(p.lon, birthUtc);
      var retrograde = false;
      if (bodyIndices.containsKey(name)) {
        final before = _planetSiderealLongitude(bodyIndices[name]!, earth, jd - 0.5, birthUtc);
        final after = _planetSiderealLongitude(bodyIndices[name]!, earth, jd + 0.5, birthUtc);
        final speed = _signedDifference(after, before);
        retrograde = speed < 0;
      }
      positions.add(GrahaPosition(
        name: name,
        longitude: longitudeSidereal,
        latitude: p.lat,
        isRetrograde: retrograde,
      ));
    }

    final ascendant = _calculateAscendant(
      jd: jd,
      latitude: latitude,
      longitudeEast: longitudeEast,
      utc: birthUtc,
    );

    return VedicKundli(
      julianDayUt: jd,
      lagnaLongitude: ascendant,
      grahas: List.unmodifiable(positions),
      moon: moon,
      vimshottari: VimshottariTimeline.fromMoonLongitude(
        moon.siderealLongitude,
        birthUtc,
      ),
    );
  }

  double _planetSiderealLongitude(
    int index,
    planets.Planet earth,
    double jd,
    DateTime utc,
  ) {
    final eq = elliptic.position(planets.Planet(index), earth, jd);
    final eps = meanObliquity(jd) + nutation(jd).dEps;
    final ecl = eqToEcl(eq.ra, eq.dec, math.sin(eps), math.cos(eps));
    return LahiriAyanamsha.siderealLongitude(toDeg(ecl.lon), utc);
  }

  double _calculateAscendant({
    required double jd,
    required double latitude,
    required double longitudeEast,
    required DateTime utc,
  }) {
    final gstHours = sidereal.siderealToHours(sidereal.apparent(jd));
    final localSiderealDegrees = _normalize(gstHours * 15 + longitudeEast);
    final theta = localSiderealDegrees * math.pi / 180;
    final phi = latitude * math.pi / 180;
    final eps = meanObliquity(jd) + nutation(jd).dEps;
    final y = math.cos(theta);
    final x = -(math.sin(eps) * math.tan(phi) +
        math.cos(eps) * math.sin(theta));
    final tropicalAscendant = _normalize(math.atan2(y, x) * 180 / math.pi);
    return LahiriAyanamsha.siderealLongitude(tropicalAscendant, utc);
  }

  static double _normalize(double value) => (value % 360 + 360) % 360;

  static double _signedDifference(double after, double before) {
    var difference = after - before;
    if (difference > 180) difference -= 360;
    if (difference < -180) difference += 360;
    return difference;
  }
}

class DashaPeriod {
  const DashaPeriod({
    required this.lord,
    required this.start,
    required this.end,
  });

  final String lord;
  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);
}

class VimshottariTimeline {
  const VimshottariTimeline({
    required this.birthMahadasha,
    required this.balanceAtBirth,
    required this.mahadashas,
  });

  static const lords = <String>[
    'केतु', 'शुक्र', 'सूर्य', 'चंद्र', 'मंगल', 'राहु', 'गुरु', 'शनि', 'बुध',
  ];
  static const years = <int>[7, 20, 6, 10, 7, 18, 16, 19, 17];
  static const totalYears = 120.0;
  static const yearDays = 365.25636;

  final String birthMahadasha;
  final Duration balanceAtBirth;
  final List<DashaPeriod> mahadashas;

  static VimshottariTimeline fromMoonLongitude(
    double moonLongitude,
    DateTime birthUtc,
  ) {
    const nakshatraWidth = 360 / 27;
    final nakIndex = (moonLongitude / nakshatraWidth).floor() % 27;
    final fractionElapsed =
        (moonLongitude % nakshatraWidth) / nakshatraWidth;
    final lordIndex = nakIndex % 9;
    final balanceYears = years[lordIndex] * (1 - fractionElapsed);
    final balance = Duration(
      microseconds: (balanceYears * yearDays * Duration.microsecondsPerDay).round(),
    );
    final periods = <DashaPeriod>[];
    var cursor = birthUtc;
    final firstEnd = cursor.add(balance);
    periods.add(DashaPeriod(lord: lords[lordIndex], start: cursor, end: firstEnd));
    cursor = firstEnd;
    for (var i = 1; i < 9; i++) {
      final index = (lordIndex + i) % 9;
      final end = cursor.add(Duration(
        microseconds: (years[index] * yearDays * Duration.microsecondsPerDay).round(),
      ));
      periods.add(DashaPeriod(lord: lords[index], start: cursor, end: end));
      cursor = end;
    }
    // Continue the cycle far enough to cover a normal lifetime.
    while (periods.length < 19) {
      final index = periods.length % 9;
      final end = cursor.add(Duration(
        microseconds: (years[index] * yearDays * Duration.microsecondsPerDay).round(),
      ));
      periods.add(DashaPeriod(lord: lords[index], start: cursor, end: end));
      cursor = end;
    }
    return VimshottariTimeline(
      birthMahadasha: lords[lordIndex],
      balanceAtBirth: balance,
      mahadashas: List.unmodifiable(periods),
    );
  }

  List<DashaPeriod> pratyantardashas(DashaPeriod antar) {
    final startIndex = lords.indexOf(antar.lord);
    final result = <DashaPeriod>[];
    var cursor = antar.start;
    for (var i = 0; i < 9; i++) {
      final index = (startIndex + i) % 9;
      final end = i == 8
          ? antar.end
          : cursor.add(Duration(
              microseconds: (antar.duration.inMicroseconds *
                      years[index] / totalYears)
                  .round(),
            ));
      result.add(DashaPeriod(lord: lords[index], start: cursor, end: end));
      cursor = end;
    }
    return result;
  }

  List<DashaPeriod> antardashas(DashaPeriod maha) {
    final startIndex = lords.indexOf(maha.lord);
    final result = <DashaPeriod>[];
    var cursor = maha.start;
    for (var i = 0; i < 9; i++) {
      final index = (startIndex + i) % 9;
      final days = maha.duration.inMicroseconds *
          (years[index] / totalYears);
      final end = i == 8
          ? maha.end
          : cursor.add(Duration(microseconds: days.round()));
      result.add(DashaPeriod(lord: lords[index], start: cursor, end: end));
      cursor = end;
    }
    return result;
  }
}
