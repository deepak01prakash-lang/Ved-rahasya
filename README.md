# Ved Rahasya

Ved Rahasya is a Flutter application for Sanatana Dharma study, devotional reading, mantra practice and introductory Vedic astrology.

## Current app modules
- Home dashboard with Veda, Bhagavad Gita, Upanishad and devotional-library entry points.
- Bhagavad Gita chapter summaries and Sanskrit verse corpus with transliteration; reviewed Hindi word glosses are clearly limited to the verses manually checked.
- Bhakti library with available Chalisa and devotional texts, with source notes where recorded.
- Mantra/japa counter with daily count and local history.
- Guided meditation timer with a simple breathing-awareness cycle.
- Birth profile with date, time, place lookup, coordinates and timezone fields.
- Vedic chart screen with Lahiri sidereal calculations, graha positions, whole-sign houses, divisional charts, drishti, strength indicators and Vimshottari periods.
- Daily sunrise Panchanga screen with tithi, vara, nakshatra, yoga, karana, sunrise and sunset.

## Run locally
1. Install Flutter stable and Android Studio.
2. Clone this repository.
3. Run `flutter pub get`.
4. Run `flutter test`.
5. Run `flutter run`.

The CI workflow generates the Android platform folder, formats Dart sources, runs tests, builds a release APK and uploads it as a GitHub Actions artifact.

## Build and signing
GitHub Actions currently uses a persistent Android **debug** signing key for sideloaded update testing. This is not the private Play Store upload key. Do not publish this CI APK to Google Play. A separate private upload keystore and protected signing secrets must be configured before store release.

## Important production gaps
- Firebase project ID/number has been created, but Firebase app registration/configuration, Authentication providers, security rules and cloud sync are not configured in this repository. There is no production login/account system yet.
- No Google Play Console organization account, verified business identity, store listing or production upload key is configured here.
- Astrology regression tests are useful safeguards, not professional ephemeris certification. Historical dates, boundary conditions and all traditional chart rules still need broader independent validation.
- Panchanga sunrise/sunset is an approximation; local Panchanga confirmation is advised for ritual timing.
- Devotional text sources and variants should continue to be checked before public release.

## Technical notes
- Flutter / Dart.
- Astronomical calculations use the `astronomia` Dart package. See [Astrology engine notes](docs/ASTROLOGY_ENGINE.md).
- User profile, bookmarks and japa progress are currently stored locally with SharedPreferences.
- No private Firebase keys or Play Store upload credentials should be committed to this repository.

## Repository workflow
GitHub Actions: https://github.com/deepak01prakash-lang/Ved-rahasya/actions
