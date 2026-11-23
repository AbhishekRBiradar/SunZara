import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'sunzara_theme_preset.dart';

class AppTypography {
  AppTypography._();

  // Headings & Section Titles: Manrope
  static TextStyle get headingLarge => GoogleFonts.manrope(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get headingMedium => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get headingSmall => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // Body, Titles & Controls: Inter
  static TextStyle get songTitle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: -0.1,
      );

  static TextStyle get artistSubtitle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      );

  // Timestamps and Durations with Tabular Figures
  static TextStyle get timestamp => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get timestampLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // Hindi Identity: Noto Sans Devanagari
  static TextStyle get hindiIdentity => GoogleFonts.notoSansDevanagari(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        letterSpacing: 0.5,
      );

  static TextStyle get hindiSubtitle => GoogleFonts.notoSansDevanagari(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  /// Generates a complete Material 3 TextTheme explicitly bound to a specific palette
  static TextTheme textThemeFor(SunZaraThemePalette palette) {
    return TextTheme(
      displayLarge: GoogleFonts.manrope(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
        letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: palette.textPrimary,
        letterSpacing: -0.1,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: palette.textSecondary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: palette.textMuted,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: palette.textMuted,
      ),
    );
  }
}
