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

## Build, Firebase and signing
GitHub Actions builds a debug-signed APK for device testing until private upload-signing secrets are configured. Once configured, it builds a Play-upload-signed Android App Bundle (AAB) and APK. The upload keystore and passwords are never stored in the repository; see [production release setup](docs/PRODUCTION_RELEASE_SETUP.md).

Firebase Email/Password authentication is implemented as an optional account screen. Until the Android app is registered and the two Firebase build values are supplied, the app remains usable in local/offline mode and the account screen explains the pending setup. No password is stored by the app itself; Firebase Authentication handles credentials.

## Important production gaps
- Firebase project ID/number has been created. Email/Password authentication UI and Firebase SDK integration are in place, but the Android app registration and Email/Password provider must still be enabled in Firebase Console. User data is still stored locally; cloud sync/security rules are not implemented.
- Google Play Console account/organization verification, store listing, and the private upload keystore/secrets are external release prerequisites.
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
