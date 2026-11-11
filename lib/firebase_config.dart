import 'package:firebase_core/firebase_core.dart';

/// Firebase options for the Android app. Values are injected at build time
/// after the Android app is registered in Firebase Console.
class FirebaseConfig {
  FirebaseConfig._();

  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String androidAppId =
      String.fromEnvironment('FIREBASE_ANDROID_APP_ID');

  static const String projectId = 'ved-rahasya';
  static const String messagingSenderId = '238694605685';

  static bool get isConfigured =>
      apiKey.isNotEmpty && androidAppId.isNotEmpty;

  static bool initialized = false;
  static String? initializationError;

  static Future<void> initialize() async {
    if (!isConfigured) return;
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: apiKey,
          appId: androidAppId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
        ),
      );
      initialized = true;
    } catch (error) {
      initializationError = error.toString();
    }
  }
}
