import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'sunzara_theme_preset.dart';

/// Central controller for dynamic theme presets and Light/Dark mode switching.
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._();

  SunZaraThemePreset _selectedPreset = SunZaraThemePreset.charcoalTeal;
  bool _isDarkMode = true;

  ThemeController._();

  SunZaraThemePreset get selectedPreset => _selectedPreset;
  SunZaraThemePreset get currentPreset => _selectedPreset;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Active palette reflecting both selected preset and Light/Dark mode
  SunZaraThemePalette get activePalette =>
      SunZaraThemePalette.forPresetAndMode(_selectedPreset, _isDarkMode);

  SunZaraThemePalette get currentPalette => activePalette;

  String get modeLabel => _isDarkMode ? 'Dark Mode' : 'Light Mode';

  IconData get modeIcon =>
      _isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded;

  /// Switches between Light and Dark mode for the currently selected theme preset
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _saveThemePreference();
  }

  /// Explicitly sets Light or Dark mode
  void setDarkMode(bool dark) {
    if (_isDarkMode != dark) {
      _isDarkMode = dark;
      notifyListeners();
      _saveThemePreference();
    }
  }

  /// Sets the selected theme preset from dropdown while preserving Light/Dark preference
  void setPreset(SunZaraThemePreset newPreset) {
    if (_selectedPreset != newPreset) {
      _selectedPreset = newPreset;
      notifyListeners();
      _saveThemePreference();
    }
  }

  /// Restores saved preset and mode from local storage
  Future<void> restoreSavedTheme() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sunzara_theme.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        final savedPresetName = json['preset'] as String?;
        if (savedPresetName != null) {
          for (final p in SunZaraThemePreset.values) {
            if (p.name == savedPresetName) {
              _selectedPreset = p;
              break;
            }
          }
        }

        if (json.containsKey('isDark')) {
          _isDarkMode = json['isDark'] as bool;
        }

        notifyListeners();
      }
    } catch (_) {
      // Graceful fallback to default
    }
  }

  Future<void> _saveThemePreference() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sunzara_theme.json');
      await file.writeAsString(jsonEncode({
        'preset': _selectedPreset.name,
        'isDark': _isDarkMode,
        'updatedAt': DateTime.now().toIso8601String(),
      }));
    } catch (_) {
      // Non-critical persistence failure ignored
    }
  }
}
