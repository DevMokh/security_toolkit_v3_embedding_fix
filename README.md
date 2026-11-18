# Security Toolkit

A Flutter security-awareness application for personal learning and authorized testing.

**Flutter package:** `security_toolkit`  
**Android application ID:** `com.security.toolkit`

## Included modules

1. **Steganography** — hide and extract text using zero-width Unicode characters. This is not encryption.
2. **AES-256-GCM** — authenticated encryption with a random salt and PBKDF2-HMAC-SHA256 key derivation.
3. **CVE Vulnerabilities** — search the public NVD CVE API and display available CVSS data.
4. **Image Metadata Awareness** — pick or capture an image, decode and re-encode it, then share the cleaned output. Re-encoding normally removes embedded EXIF metadata; verify the output before sharing.
5. **Phishing Awareness Lab** — generate clearly labelled simulation messages using the safe `example.com` training domain.
6. **Link Scanner** — local URL-structure heuristics. It does not open the URL or upload it.
7. **Server Status & WebView** — check NVD reachability and use an HTTPS-only embedded WebView with JavaScript disabled.

## Generate the Android project

The Android manifest is included. Flutter's current Android Gradle wrapper and platform files are generated from the installed stable Flutter SDK:

```bash
bash scripts/bootstrap_android.sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

The bootstrap script sets both Android `applicationId` and `namespace` to `com.security.toolkit`, updates the Kotlin MainActivity package, and sets minimum Android SDK to 24. Use Flutter stable with Dart 3.11 or newer.

## GitHub Actions

Push the project to GitHub. The workflow uses Java 17 and Flutter stable, generates the native Android project, analyzes the Dart source, runs tests, builds the release APK and uploads it as an artifact.

## Permissions and privacy

- Internet: used for NVD CVE queries and the connectivity check.
- Camera: requested only when the user chooses to capture an image.
- Android's system photo picker is used for image selection. Broad storage read/write permissions are not needed for this flow.
- No system overlay permission is requested because the app does not need to draw over other applications.
- No Telegram bot token, Chat ID, or automatic startup beacon is embedded in the app. A bot token inside an APK can be extracted. For operational notifications, use a backend that stores secrets server-side and make notification sending an explicit user choice.

## Safety boundaries

This app does not generate functional malicious links, credential-harvesting pages, exploit payloads, or executable image payloads. Phishing content is labelled as a simulation, uses `example.com`, and is intended for awareness training. Only test systems and data for which you have authorization.

## Notes

- The URL score is a heuristic indicator, not a probability or a guarantee that a link is safe or malicious.
- The image tool re-encodes supported images. It does not claim to remove every conceivable metadata channel from every image format.
- A successful build has not been asserted until GitHub Actions or a local Flutter SDK completes the workflow.


## Android build pipeline update

The GitHub Actions workflow regenerates the Android host project using the current Flutter stable template, writes a V2 `MainActivity`, normalizes `AndroidManifest.xml` to `flutterEmbedding=2`, and validates the manifest/activity before dependency analysis and APK compilation. The workflow uses Node 24-compatible GitHub actions and pins the hosted runner to Ubuntu 24.04.

The APK is uploaded as the `security-toolkit-release` workflow artifact after a successful release build.
