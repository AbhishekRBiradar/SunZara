import 'package:flutter/material.dart';
import 'sunzara_theme_preset.dart';
import 'theme_controller.dart';

/// SunZara Theme Colors System
/// Fully dynamic and synchronized with the active [SunZaraThemePalette].
class AppColors {
  AppColors._();

  // Active Dynamic Palette
  static SunZaraThemePalette get current => ThemeController.instance.currentPalette;

  // Adaptive Getters reacting to active Theme
  static Color get background => current.background;
  static Color get surface => current.surface;
  static Color get surfaceElevated => current.surfaceElevated;
  static Color get surfaceHighlight => current.surfaceHighlight;
  static Color get textPrimary => current.textPrimary;
  static Color get textSecondary => current.textSecondary;
  static Color get textMuted => current.textMuted;
  static Color get divider => current.divider;
  static Color get primary => current.primary;
  static Color get primaryPressed => current.primaryPressed;
  static Color get primaryGlow => current.primaryGlow;
  static Color get error => current.error;
  static Color get success => current.success;

  // Static constants for fallback & specific overrides
  static const Color darkBackground = Color(0xFF090907);
  static const Color darkSurface = Color(0xFF151714);
  static const Color darkSurfaceElevated = Color(0xFF1D2421);
  static const Color darkSurfaceHighlight = Color(0xFF253638);
  static const Color darkTextPrimary = Color(0xFFE8E4D3);
  static const Color darkTextSecondary = Color(0xFFAAA99E);
  static const Color darkTextMuted = Color(0xFF77796F);
  static const Color darkDivider = Color(0xFF303630);

  static const Color lightBackground = Color(0xFFF7F6F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFEDEBE3);
  static const Color lightSurfaceHighlight = Color(0xFFE0F3F5);
  static const Color lightTextPrimary = Color(0xFF181A16);
  static const Color lightTextSecondary = Color(0xFF5D6056);
  static const Color lightTextMuted = Color(0xFF888B80);
  static const Color lightDivider = Color(0xFFDFDDD3);

  // Brand Accents
  static const Color brandTeal = Color(0xFF00AEBB);
  static const Color deepPetrol = Color(0xFF1D2421);
  static const Color stoneGrey = Color(0xFFAAA99E);
  static const Color warmIvory = Color(0xFFE8E4D3);
}
