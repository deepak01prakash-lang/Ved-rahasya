# Ved Rahasya astrology engine — implementation notes

## Calculation policy

- Primary target: Drik-style astronomical calculations, Lahiri/Chitrapaksha sidereal zodiac, local birth time converted to UTC using the birth location's historical time zone.
- Never infer a Vedic Moon sign, Ascendant, Nakshatra, or Panchanga from date-only Western Sun-sign ranges.
- Never show a gemstone as a guaranteed remedy. Explain that gemstone and devotional associations are traditional beliefs.

## Dependency and licensing

The first calculation foundation uses the MIT-licensed Dart package `astronomia` (Meeus-based algorithms). It provides astronomical primitives without embedding the Swiss Ephemeris licensing obligations in the application. Package details: https://pub.dev/packages/astronomia

A Swiss Ephemeris-based package was evaluated but not adopted because its underlying Swiss Ephemeris engine is GPL/commercial dual-licensed. Before adopting it in a distributable app, the project owner must deliberately choose GPL-compatible distribution or obtain the applicable commercial license.

## Implemented foundation

- UTC Julian Day conversion.
- Geocentric apparent tropical Sun and Moon ecliptic longitudes.
- Lunar elongation and illuminated fraction.
- A smoke test around the J2000 epoch.

These outputs are internal astronomical primitives only. They are **not yet** Vedic sidereal results.

## Next implementation gates

1. Validate Lahiri ayanamsa implementation against published reference dates.
2. Resolve city/place to latitude, longitude, and historical IANA time zone; retain manual correction.
3. Convert birth wall-clock time to UTC without assuming the phone's current time zone.
4. Add sidereal planetary positions, Moon sign, Nakshatra/pada, Ascendant and houses.
5. Add Panchanga: Tithi, Vara, Nakshatra, Yoga, Karana, sunrise/sunset, local day boundary and muhurta.
6. Cross-check a diverse golden test set against at least two reputable Panchanga/ephemeris references before exposing results.
7. Add transits, Dashas, compatibility and daily horoscope content only after their calculation outputs are validated.

## Not yet implemented

No production Vedic chart, daily Panchanga, transit forecast, horoscope prediction, geocoding, or birth-place time-zone resolution is claimed by this foundation commit.
