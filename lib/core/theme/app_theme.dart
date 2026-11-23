import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_typography.dart';
import 'sunzara_theme_preset.dart';
import 'theme_controller.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get currentTheme =>
      createThemeData(ThemeController.instance.currentPalette);

  static ThemeData get darkTheme =>
      createThemeData(SunZaraThemePalette.charcoalTeal);

  static ThemeData get lightTheme =>
      createThemeData(SunZaraThemePalette.warmIvory);

  static ThemeData createThemeData(SunZaraThemePalette palette) {
    final isDark = palette.isDark;

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: palette.primary,
            onPrimary: palette.background,
            primaryContainer: palette.surfaceHighlight,
            onPrimaryContainer: palette.textPrimary,
            surface: palette.surface,
            onSurface: palette.textPrimary,
            error: palette.error,
            onError: palette.background,
          )
        : ColorScheme.light(
            primary: palette.primary,
            onPrimary: Colors.white,
            primaryContainer: palette.surfaceHighlight,
            onPrimaryContainer: palette.textPrimary,
            surface: palette.surface,
            onSurface: palette.textPrimary,
            error: palette.error,
            onError: Colors.white,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.primary,
      canvasColor: palette.background,
      dividerColor: palette.divider,
      colorScheme: colorScheme,
      textTheme: AppTypography.textThemeFor(palette),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 68,
        titleTextStyle: AppTypography.headingMedium.copyWith(color: palette.textPrimary),
        iconTheme: IconThemeData(color: palette.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: palette.surface,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.divider, width: 0.6),
        ),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        textColor: palette.textPrimary,
        iconColor: palette.textSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: isDark ? palette.background : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary.withAlpha(200), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppTypography.headingMedium.copyWith(color: palette.textPrimary),
        contentTextStyle: AppTypography.body.copyWith(color: palette.textPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.primary,
        inactiveTrackColor: palette.divider,
        thumbColor: palette.textPrimary,
        overlayColor: palette.primaryGlow,
        trackHeight: 3.5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceElevated,
        contentTextStyle: AppTypography.body.copyWith(color: palette.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.surfaceHighlight,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption.copyWith(
              color: palette.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.caption.copyWith(color: palette.textMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: palette.primary, size: 24);
          }
          return IconThemeData(color: palette.textSecondary, size: 24);
        }),
      ),
    );
  }
}
