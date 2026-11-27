import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Immutable semantic version and Android build code metadata for SunZara.
class AppVersionInfo {
  /// Default version used when native package metadata is unavailable (e.g. unit tests).
  static const AppVersionInfo fallback = AppVersionInfo(
    versionName: '1.1.0',
    buildNumber: 2,
  );

  final String versionName;
  final int buildNumber;

  const AppVersionInfo({
    required this.versionName,
    required this.buildNumber,
  });

  /// Human-readable label shown in the Settings About card.
  String get displayLabel => 'Version $versionName (Build $buildNumber)';
}

/// Reads the live installed application version from the host platform channel.
class AppVersionService {
  static const MethodChannel _channel = MethodChannel('com.sunzara.app/app_info');
  static final AppVersionService instance = AppVersionService._();

  AppVersionInfo? _cached;

  /// Optional override allowing widget/unit tests to simulate installed versions.
  @visibleForTesting
  Future<AppVersionInfo> Function()? testLoader;

  AppVersionService._();

  /// Resolves the installed package version, caching the first successful read.
  Future<AppVersionInfo> getVersionInfo() async {
    if (testLoader != null) {
      return testLoader!();
    }
    if (_cached != null) return _cached!;
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('getPackageVersion');
      if (raw != null) {
        final name = (raw['versionName'] as String?)?.trim();
        final codeRaw = raw['versionCode'];
        final code = codeRaw is int
            ? codeRaw
            : (codeRaw is num ? codeRaw.toInt() : AppVersionInfo.fallback.buildNumber);
        if (name != null && name.isNotEmpty) {
          _cached = AppVersionInfo(versionName: name, buildNumber: code);
          return _cached!;
        }
      }
    } on MissingPluginException {
      // Headless / widget-test environments use the compile-time fallback.
    } catch (_) {
      // Fall back cleanly if platform lookup fails.
    }
    return AppVersionInfo.fallback;
  }

  /// Clears cached metadata and overrides (intended for tests).
  @visibleForTesting
  void resetCache() {
    _cached = null;
    testLoader = null;
  }
}
