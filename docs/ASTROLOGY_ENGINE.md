# Ved Rahasya astrology engine — implementation and validation status

## Calculation policy
- Birth date, wall-clock time, coordinates, and historical time-zone data are used where supplied.
- Sidereal chart output uses the Lahiri ayanamsha implementation in this repository.
- Moon sign, ascendant, nakshatra/pada, divisional charts, graha drishti, strength indicators and Vimshottari periods are calculated in-app.
- Gemstone, deity and mantra associations are presented as traditional references, not guaranteed remedies or scientific predictions.
- Panchanga is sunrise-oriented and should be cross-checked with a trusted local Panchanga for ritual/muhurta decisions.

## Dependencies and licensing
The current astronomical foundation uses the MIT-licensed Dart package `astronomia` (Meeus-based algorithms): https://pub.dev/packages/astronomia.
Swiss Ephemeris was not bundled. Its GPL/commercial dual licensing would require a deliberate distribution/licensing decision before adoption.

## Implemented
- Julian Day and astronomical position helpers.
- Lahiri sidereal longitude conversion.
- Nine graha positions, Ascendant and whole-sign houses.
- Navamsha and divisional chart calculations (D2, D3, D4, D7, D9, D10, D12, D16, D20, D24, D27, D30, D40, D45, D60).
- Vimshottari Mahadasha, Antardasha and Pratyantardasha timeline generation.
- Graha drishti and preliminary strength/yoga indicators.
- Birth-place geocoding and IANA timezone lookup in the profile screen, with manual coordinate/UTC-offset fields.
- Sunrise Panchanga fields: tithi, vara, nakshatra, yoga, karana, sunrise and sunset.
- Regression/unit tests including a J2000 planetary-position reference comparison and selected divisional/dasha rules.

## Validation status and limitations
- CI runs `dart format lib test`, `flutter test`, and a release APK build. The most recent successful run is visible in GitHub Actions.
- The J2000 test is a regression check at one epoch; it is not a comprehensive ephemeris certification.
- All historical dates, extreme latitudes, sign-boundary cases, timezone transitions and every divisional-chart convention have not been exhaustively cross-validated against two independent professional ephemerides.
- Sunrise/sunset use a compact solar-event approximation; altitude, local horizon, refraction and regional conventions can cause differences.
- Panchanga values are calculated near sunrise. Tithi/nakshatra transitions during the day and location-specific muhurta windows are not yet shown as full transition tables.
- Yoga detection is preliminary and should not be treated as a definitive classical yoga judgement without checking all traditional conditions, aspects, combustion, dignity and chart context.
- The app does not promise fate, health, financial or relationship outcomes. Interpretive text is educational and tradition-based.

## Further verification gates
1. Compare a golden set of dates and locations (including DST/timezone-history boundaries) against at least two reputable independent ephemerides.
2. Verify each divisional-chart convention and Vimshottari boundary handling against documented classical references.
3. Validate sunrise Panchanga transitions against location-specific Panchanga references across multiple dates.
4. Expand boundary/property-based tests before describing the engine as professionally certified.
