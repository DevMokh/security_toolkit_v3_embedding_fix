# Security Toolkit — Android V1 embedding build fix

This archive is arranged with the Flutter project files directly at the archive root.

## Important import rule

When importing this archive into the GitHub repository, place the **contents** of this folder at the repository root. The root must directly contain:

- `.github/workflows/build.yml`
- `pubspec.yaml`
- `lib/main.dart`
- `scripts/bootstrap_android.sh`

Do not place the whole project inside an extra `security_toolkit_complete/` directory. The workflow now checks the repository root and stops with a clear message if the project was uploaded one folder too deep.

## What the workflow does

1. Regenerates the Android host project from the installed Flutter template.
2. Rewrites the app manifest so it contains exactly one `flutterEmbedding=2` entry and no legacy `FlutterApplication` declaration.
3. Installs a V2 `MainActivity` using `io.flutter.embedding.android.FlutterActivity`.
4. Verifies the manifest and activity before running dependency resolution or building.
5. Runs `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter build apk --release`.
6. Uploads `app-release.apk` as the `security-toolkit-release` artifact.

The build workflow is pinned to Flutter 3.47.2 and Java 17 to match the toolchain shown in the supplied failed run.
