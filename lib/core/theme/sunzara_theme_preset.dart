import 'package:flutter/material.dart';

enum SunZaraThemePreset {
  charcoalTeal,
  warmIvory,
  midnightAmoled,
  sunsetAmber,
  deepOcean,
  emeraldForest,
}

extension SunZaraThemePresetExtension on SunZaraThemePreset {
  String get displayName {
    switch (this) {
      case SunZaraThemePreset.charcoalTeal:
        return 'Charcoal Teal';
      case SunZaraThemePreset.warmIvory:
        return 'Warm Ivory';
      case SunZaraThemePreset.midnightAmoled:
        return 'Midnight AMOLED';
      case SunZaraThemePreset.sunsetAmber:
        return 'Sunset Amber';
      case SunZaraThemePreset.deepOcean:
        return 'Deep Ocean';
      case SunZaraThemePreset.emeraldForest:
        return 'Emerald Forest';
    }
  }

  Color get primaryAccent {
    switch (this) {
      case SunZaraThemePreset.charcoalTeal:
        return const Color(0xFF00AEBB);
      case SunZaraThemePreset.warmIvory:
        return const Color(0xFF008E98);
      case SunZaraThemePreset.midnightAmoled:
        return const Color(0xFF00E5FF);
      case SunZaraThemePreset.sunsetAmber:
        return const Color(0xFFFFB300);
      case SunZaraThemePreset.deepOcean:
        return const Color(0xFF00D2D3);
      case SunZaraThemePreset.emeraldForest:
        return const Color(0xFF10B981);
    }
  }
}

class SunZaraThemePalette {
  final SunZaraThemePreset preset;
  final String id;
  final String name;
  final String subtitle;
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceHighlight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color divider;
  final Color primary;
  final Color primaryPressed;
  final Color primaryGlow;
  final Color error;
  final Color success;

  const SunZaraThemePalette({
    required this.preset,
    required this.id,
    required this.name,
    required this.subtitle,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHighlight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.primary,
    required this.primaryPressed,
    required this.primaryGlow,
    this.error = const Color(0xFFE47777),
    this.success = const Color(0xFF8BAE9B),
  });

  bool get isDark => brightness == Brightness.dark;

  // 1. Charcoal Teal
  static const SunZaraThemePalette charcoalTealDark = SunZaraThemePalette(
    preset: SunZaraThemePreset.charcoalTeal,
    id: 'charcoal_teal_dark',
    name: 'Charcoal Teal',
    subtitle: 'Deep charcoal canvas with electric teal',
    brightness: Brightness.dark,
    background: Color(0xFF090907),
    surface: Color(0xFF151714),
    surfaceElevated: Color(0xFF1D2421),
    surfaceHighlight: Color(0xFF253638),
    textPrimary: Color(0xFFE8E4D3),
    textSecondary: Color(0xFFAAA99E),
    textMuted: Color(0xFF77796F),
    divider: Color(0xFF303630),
    primary: Color(0xFF00AEBB),
    primaryPressed: Color(0xFF008E98),
    primaryGlow: Color(0x3300AEBB),
  );

  static const SunZaraThemePalette charcoalTealLight = SunZaraThemePalette(
    preset: SunZaraThemePreset.charcoalTeal,
    id: 'charcoal_teal_light',
    name: 'Charcoal Teal',
    subtitle: 'Crisp soft silver canvas with electric teal',
    brightness: Brightness.light,
    background: Color(0xFFF4F6F6),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFE8ECEB),
    surfaceHighlight: Color(0xFFE0F4F6),
    textPrimary: Color(0xFF151817),
    textSecondary: Color(0xFF5A615E),
    textMuted: Color(0xFF828C88),
    divider: Color(0xFFDCE2E1),
    primary: Color(0xFF008E98),
    primaryPressed: Color(0xFF006D75),
    primaryGlow: Color(0x28008E98),
  );

  // 2. Warm Ivory
  static const SunZaraThemePalette warmIvoryDark = SunZaraThemePalette(
    preset: SunZaraThemePreset.warmIvory,
    id: 'warm_ivory_dark',
    name: 'Warm Ivory',
    subtitle: 'Warm dark sepia canvas with ivory & teal',
    brightness: Brightness.dark,
    background: Color(0xFF141311),
    surface: Color(0xFF1F1D19),
    surfaceElevated: Color(0xFF2B2823),
    surfaceHighlight: Color(0xFF38332A),
    textPrimary: Color(0xFFF7F3E8),
    textSecondary: Color(0xFFB5ADA0),
    textMuted: Color(0xFF7A7367),
    divider: Color(0xFF3B362D),
    primary: Color(0xFF00AEBB),
    primaryPressed: Color(0xFF008E98),
    primaryGlow: Color(0x3300AEBB),
  );

  static const SunZaraThemePalette warmIvoryLight = SunZaraThemePalette(
    preset: SunZaraThemePreset.warmIvory,
    id: 'warm_ivory_light',
    name: 'Warm Ivory',
    subtitle: 'Signature clean warm ivory canvas with teal',
    brightness: Brightness.light,
    background: Color(0xFFF7F6F2),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEDEBE3),
    surfaceHighlight: Color(0xFFE0F3F5),
    textPrimary: Color(0xFF181A16),
    textSecondary: Color(0xFF5D6056),
    textMuted: Color(0xFF888B80),
    divider: Color(0xFFDFDDD3),
    primary: Color(0xFF008E98),
    primaryPressed: Color(0xFF006D75),
    primaryGlow: Color(0x28008E98),
  );

  // 3. Midnight AMOLED
  static const SunZaraThemePalette midnightAmoledDark = SunZaraThemePalette(
    preset: SunZaraThemePreset.midnightAmoled,
    id: 'midnight_amoled_dark',
    name: 'Midnight AMOLED',
    subtitle: 'Pitch black battery saver with cyber cyan',
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    surface: Color(0xFF0D0F13),
    surfaceElevated: Color(0xFF161920),
    surfaceHighlight: Color(0xFF1A2633),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA5ACB8),
    textMuted: Color(0xFF6B7280),
    divider: Color(0xFF222631),
    primary: Color(0xFF00E5FF),
    primaryPressed: Color(0xFF00B8CC),
    primaryGlow: Color(0x3800E5FF),
  );

  static const SunZaraThemePalette midnightAmoledLight = SunZaraThemePalette(
    preset: SunZaraThemePreset.midnightAmoled,
    id: 'midnight_amoled_light',
    name: 'Midnight AMOLED',
    subtitle: 'Icy white canvas with electric cyan',
    brightness: Brightness.light,
    background: Color(0xFFF0F4F8),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFE2E8F0),
    surfaceHighlight: Color(0xFFE0F2FE),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    divider: Color(0xFFCBD5E1),
    primary: Color(0xFF0284C7),
    primaryPressed: Color(0xFF0369A1),
    primaryGlow: Color(0x280284C7),
  );

  // 4. Sunset Amber
  static const SunZaraThemePalette sunsetAmberDark = SunZaraThemePalette(
    preset: SunZaraThemePreset.sunsetAmber,
    id: 'sunset_amber_dark',
    name: 'Sunset Amber',
    subtitle: 'Warm espresso canvas with honey amber gold',
    brightness: Brightness.dark,
    background: Color(0xFF100C09),
    surface: Color(0xFF1B1511),
    surfaceElevated: Color(0xFF261E18),
    surfaceHighlight: Color(0xFF382A1F),
    textPrimary: Color(0xFFFDF0DB),
    textSecondary: Color(0xFFBAA995),
    textMuted: Color(0xFF7F7263),
    divider: Color(0xFF382B20),
    primary: Color(0xFFFFB300),
    primaryPressed: Color(0xFFD69500),
    primaryGlow: Color(0x38FFB300),
  );

  static const SunZaraThemePalette sunsetAmberLight = SunZaraThemePalette(
    preset: SunZaraThemePreset.sunsetAmber,
    id: 'sunset_amber_light',
    name: 'Sunset Amber',
    subtitle: 'Sunny peach-cream canvas with warm amber',
    brightness: Brightness.light,
    background: Color(0xFFFAF5EE),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF3ECE0),
    surfaceHighlight: Color(0xFFFEF3C7),
    textPrimary: Color(0xFF1A130E),
    textSecondary: Color(0xFF6B5848),
    textMuted: Color(0xFF9C8775),
    divider: Color(0xFFE5DAC9),
    primary: Color(0xFFD97706),
    primaryPressed: Color(0xFFB45309),
    primaryGlow: Color(0x28D97706),
  );

  // 5. Deep Ocean
  static const SunZaraThemePalette deepOceanDark = SunZaraThemePalette(
    preset: SunZaraThemePreset.deepOcean,
    id: 'deep_ocean_dark',
    name: 'Deep Ocean',
    subtitle: 'Midnight navy abyss with luminous aquamarine',
    brightness: Brightness.dark,
    background: Color(0xFF060B12),
    surface: Color(0xFF0D1624),
    surfaceElevated: Color(0xFF152236),
    surfaceHighlight: Color(0xFF1D324E),
    textPrimary: Color(0xFFE8F1FA),
    textSecondary: Color(0xFF9CB2C9),
    textMuted: Color(0xFF647B94),
    divider: Color(0xFF1F334E),
    primary: Color(0xFF00D2D3),
    primaryPressed: Color(0xFF01A3A4),
    primaryGlow: Color(0x3800D2D3),
  );

  static const SunZaraThemePalette deepOceanLight = SunZaraThemePalette(
    preset: SunZaraThemePreset.deepOcean,
    id: 'deep_ocean_light',
    name: 'Deep Ocean',
    subtitle: 'Nautical sky canvas with marine ocean cyan',
    brightness: Brightness.light,
    background: Color(0xFFF0F6FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFE1EDF5),
    surfaceHighlight: Color(0xFFE0F7FA),
    textPrimary: Color(0xFF0C1929),
    textSecondary: Color(0xFF3E5671),
    textMuted: Color(0xFF7A93AF),
    divider: Color(0xFFCCE0ED),
    primary: Color(0xFF0891B2),
    primaryPressed: Color(0xFF0E7490),
    primaryGlow: Color(0x280891B2),
  );

  // 6. Emerald Forest
  static const SunZaraThemePalette emeraldForestDark = SunZaraThemePalette(
    preset: SunZaraThemePreset.emeraldForest,
    id: 'emerald_forest_dark',
    name: 'Emerald Forest',
    subtitle: 'Deep pine canvas with radiant emerald',
    brightness: Brightness.dark,
    background: Color(0xFF07100A),
    surface: Color(0xFF0E1C13),
    surfaceElevated: Color(0xFF16291C),
    surfaceHighlight: Color(0xFF1F3B29),
    textPrimary: Color(0xFFE8F6ED),
    textSecondary: Color(0xFF9EBAA8),
    textMuted: Color(0xFF6A8674),
    divider: Color(0xFF203B2B),
    primary: Color(0xFF10B981),
    primaryPressed: Color(0xFF059669),
    primaryGlow: Color(0x3810B981),
  );

  static const SunZaraThemePalette emeraldForestLight = SunZaraThemePalette(
    preset: SunZaraThemePreset.emeraldForest,
    id: 'emerald_forest_light',
    name: 'Emerald Forest',
    subtitle: 'Fresh sage canvas with lush emerald',
    brightness: Brightness.light,
    background: Color(0xFFF1F7F3),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFE2EFE6),
    surfaceHighlight: Color(0xFFDCFCE7),
    textPrimary: Color(0xFF072614),
    textSecondary: Color(0xFF385E46),
    textMuted: Color(0xFF6F997E),
    divider: Color(0xFFCBE0D2),
    primary: Color(0xFF059669),
    primaryPressed: Color(0xFF047857),
    primaryGlow: Color(0x28059669),
  );

  // Backwards-compatible constants
  static const SunZaraThemePalette charcoalTeal = charcoalTealDark;
  static const SunZaraThemePalette warmIvory = warmIvoryLight;
  static const SunZaraThemePalette midnightAmoled = midnightAmoledDark;
  static const SunZaraThemePalette sunsetAmber = sunsetAmberDark;
  static const SunZaraThemePalette deepOcean = deepOceanDark;
  static const SunZaraThemePalette emeraldForest = emeraldForestDark;

  static const List<SunZaraThemePreset> allPresets = SunZaraThemePreset.values;

  static SunZaraThemePalette forPresetAndMode(SunZaraThemePreset preset, bool isDark) {
    switch (preset) {
      case SunZaraThemePreset.charcoalTeal:
        return isDark ? charcoalTealDark : charcoalTealLight;
      case SunZaraThemePreset.warmIvory:
        return isDark ? warmIvoryDark : warmIvoryLight;
      case SunZaraThemePreset.midnightAmoled:
        return isDark ? midnightAmoledDark : midnightAmoledLight;
      case SunZaraThemePreset.sunsetAmber:
        return isDark ? sunsetAmberDark : sunsetAmberLight;
      case SunZaraThemePreset.deepOcean:
        return isDark ? deepOceanDark : deepOceanLight;
      case SunZaraThemePreset.emeraldForest:
        return isDark ? emeraldForestDark : emeraldForestLight;
    }
  }

  static SunZaraThemePalette forPreset(SunZaraThemePreset preset) {
    return forPresetAndMode(preset, true);
  }

  static SunZaraThemePalette fromId(String id) {
    for (final preset in SunZaraThemePreset.values) {
      if (id.startsWith(preset.name)) {
        return forPresetAndMode(preset, !id.endsWith('light'));
      }
    }
    return charcoalTealDark;
  }
}
