# Production setup: Firebase and Google Play

This repository now has optional Firebase Email/Password authentication and a CI path for a privately signed Android App Bundle. Do not commit Firebase configuration values, keystores, passwords, or service-account files.

## 1. Register the Android app in Firebase

Firebase project:
- Project ID: `ved-rahasya`
- Project number / sender ID: `238694605685`
- Android package name: `com.vedrahasya.ved_rahasya`

In Firebase Console:
1. Open the existing `ved-rahasya` project.
2. Add an Android app with package name exactly `com.vedrahasya.ved_rahasya`.
3. Download or note the Android app's Firebase App ID and Web API key (Project settings → General).
4. In Authentication → Sign-in method, enable **Email/Password**.
5. In Authentication → Settings, configure authorized domains only if using web sign-in; the native Android email/password flow does not need a web domain.
6. Add these GitHub repository Actions secrets (Settings → Secrets and variables → Actions → New repository secret):
   - `FIREBASE_API_KEY`: Firebase project's Web API key.
   - `FIREBASE_ANDROID_APP_ID`: the registered Android app's Firebase App ID (starts with `1:`).
7. Push to `main` or run the Android workflow manually. The app's account icon will then open Firebase-backed create-account, login, email-verification and password-reset flows.

The Firebase API key and App ID identify the Firebase client; they are not substitutes for server credentials. Never put Firebase Admin service-account JSON in the mobile app or GitHub build variables.

## 2. Configure private Play upload signing

Create a long-lived upload keystore on a trusted computer with Java's `keytool`:

```bash
keytool -genkeypair -v -keystore ved-rahasya-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ved-rahasya-upload
```

Keep the keystore and its passwords in a secure password manager and offline backup. Losing the upload key can complicate future releases. Do not send it in chat or commit it to Git.

Convert the keystore to one-line Base64:
- Linux: `base64 -w 0 ved-rahasya-upload.jks`
- macOS: `base64 < ved-rahasya-upload.jks | tr -d '\n'`
- Windows PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("ved-rahasya-upload.jks"))`

Add these GitHub Actions repository secrets:
- `ANDROID_UPLOAD_KEYSTORE_BASE64`: the Base64 output.
- `ANDROID_UPLOAD_KEYSTORE_PASSWORD`: keystore password.
- `ANDROID_UPLOAD_KEY_ALIAS`: `ved-rahasya-upload` (or the alias you chose).
- `ANDROID_UPLOAD_KEY_PASSWORD`: key password.

Once all four secrets exist, the workflow will sign and upload both `app-release.aab` and `app-release.apk`. Until then it deliberately produces only a debug-signed test APK. The keystore is decoded only into the temporary GitHub runner and is not retained as a repository file.

## 3. Google Play Console account and first release

1. Create/verify the Play Console developer account using the legal account type that matches the actual owner. Do not select an organization unless you can provide the requested organization identity and D-U-N-S information.
2. Complete developer identity/contact verification and any requested payments.
3. Create the app listing for **Ved Rahasya**, select the correct app category, complete privacy policy, Data safety, content rating, target audience and app-access declarations.
4. Enrol in Play App Signing when prompted; upload the AAB produced by the workflow.
5. Complete the required testing track and any new-account testing requirement before production rollout.

The repository owner must complete legal identity checks and accept Play Console agreements personally. Do not publish the current debug-signed APK to Play.

## 4. Current scope and safeguards

- Login uses Firebase Authentication. It does not yet sync profile, bookmarks, japa history or kundli data to the cloud.
- Do not collect/store a user's password in SharedPreferences or Firestore.
- Before adding cloud sync, define Firestore rules that restrict each user's documents to their authenticated UID and test those rules.
- Email verification is sent after account creation; production policy should decide whether unverified accounts can access any future cloud features.
