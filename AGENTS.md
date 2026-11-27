# SunZara Versioning Policy

Whenever any code, UI, resource, configuration, or native Android change is made to SunZara before building or installing:

1. Increment `version: X.Y.Z+N` in `pubspec.yaml`:
   - Always increment `+N` (`buildNumber` / Android `versionCode`) by at least `1`.
   - Bump `Z` (patch) for bug fixes or small tweaks, and bump `Y` (minor, resetting `Z` to `0`) for user-visible features or UI changes.
2. Keep `AppVersionInfo.fallback` in `lib/core/services/app_version_service.dart` synced to the exact same `versionName` and `buildNumber`.
3. Run `flutter test --no-pub test/core/app_version_test.dart` (which enforces `pubspec.yaml` and `AppVersionInfo.fallback` stay in lockstep) before building the release APK.
