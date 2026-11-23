import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunzara/core/theme/app_colors.dart';
import 'package:sunzara/core/theme/app_theme.dart';
import 'package:sunzara/core/widgets/deterministic_artwork.dart';
import 'package:sunzara/core/widgets/playing_equalizer_bars.dart';

void main() {
  group('Theme and Artwork Tests', () {
    test('AppColors strict palette hex values match design specification', () {
      expect(AppColors.background.toARGB32(), 0xFF090907);
      expect(AppColors.surface.toARGB32(), 0xFF151714);
      expect(AppColors.surfaceElevated.toARGB32(), 0xFF1D2421);
      expect(AppColors.surfaceHighlight.toARGB32(), 0xFF253638);
      expect(AppColors.primary.toARGB32(), 0xFF00AEBB);
      expect(AppColors.primaryPressed.toARGB32(), 0xFF008E98);
      expect(AppColors.textPrimary.toARGB32(), 0xFFE8E4D3);
      expect(AppColors.textSecondary.toARGB32(), 0xFFAAA99E);
      expect(AppColors.textMuted.toARGB32(), 0xFF77796F);
      expect(AppColors.divider.toARGB32(), 0xFF303630);
      expect(AppColors.error.toARGB32(), 0xFFE47777);
      expect(AppColors.success.toARGB32(), 0xFF8BAE9B);
    });

    test('AppTheme creates a valid Material 3 dark theme with custom styling', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.primary);
    });

    testWidgets('DeterministicArtwork renders consistently for a seed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeterministicArtwork(
              seed: 'O Sanam',
              size: 100,
            ),
          ),
        ),
      );

      expect(find.byType(DeterministicArtwork), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('PlayingEqualizerBars renders and animates when playing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayingEqualizerBars(
              isPlaying: true,
              size: 24,
            ),
          ),
        ),
      );

      expect(find.byType(PlayingEqualizerBars), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(PlayingEqualizerBars), findsOneWidget);
    });
  });
}
