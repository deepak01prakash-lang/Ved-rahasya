# Ved Rahasya – Personal Video Studio

A free-first, private-use Flutter Android starter for planning Hindi devotional and mystery videos.

## Included in this first build
- Topic and user-script inputs.
- Shorts (9:16) and long-video (16:9) project settings.
- A detailed Hindi production prompt for ChatGPT: hook, script, scene plan, narration, visual prompts, camera, sound and source-check instructions.
- One-tap prompt copy and ChatGPT launch.
- Android text-to-speech preview using the phone's installed Hindi voice where available.
- Local project drafts using SharedPreferences.

## Honest limitations
This first build does **not** generate AI video clips or render/export MP4. ChatGPT can help create the script and scene prompts, but actual moving AI clips require a video-generation provider; free unlimited generation cannot be promised. No paid provider or API key is included.

## Build Android APK
From this directory:
1. Install Flutter stable and Android SDK.
2. Run `flutter create --platforms=android --project-name ved_rahasya_video_studio --org com.vedrahasya .`
3. Run `flutter pub get`
4. Run `flutter analyze`
5. Run `flutter build apk --release`

The GitHub Actions workflow in the parent repository also builds a debug APK artifact when this folder changes.
