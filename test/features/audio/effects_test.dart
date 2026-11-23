import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunzara/features/now_playing/presentation/equalizer_controller.dart';
import 'package:sunzara/features/now_playing/presentation/widgets/visualizer_widget.dart';

void main() {
  group('Equalizer Controller & Model Tests', () {
    test('EqualizerBand frequency and dB formatting', () {
      const bandLow = EqualizerBand(
        index: 0,
        centerFreqHz: 60,
        level: 300,
        minLevel: -1500,
        maxLevel: 1500,
      );
      expect(bandLow.formattedFreq, '60');
      expect(bandLow.formattedDb, '+3 dB');

      const bandMid = EqualizerBand(
        index: 1,
        centerFreqHz: 1000,
        level: -450,
        minLevel: -1500,
        maxLevel: 1500,
      );
      expect(bandMid.formattedFreq, '1k');
      expect(bandMid.formattedDb, '-5 dB');

      const bandHigh = EqualizerBand(
        index: 2,
        centerFreqHz: 14000,
        level: 0,
        minLevel: -1500,
        maxLevel: 1500,
      );
      expect(bandHigh.formattedFreq, '14k');
      expect(bandHigh.formattedDb, '+0 dB');
    });

    test('EqualizerController fallback bands initialization and adjustment', () async {
      final controller = EqualizerController();
      // Initialize with session
      await controller.initAudioSession(1234);

      expect(controller.state.isSupported, isTrue);
      expect(controller.state.bands.length, 5);

      // Adjust band 0
      await controller.setBandLevel(0, 600);
      expect(controller.state.bands[0].level, 600);
      expect(controller.state.bands[0].formattedDb, '+6 dB');

      // Adjust bass boost
      await controller.setBassBoost(500);
      expect(controller.state.bassBoostStrength, 500);

      // Select preset
      await controller.usePreset(1);
      expect(controller.state.selectedPresetIndex, 1);
    });

    testWidgets('VisualizerWidget renders in all modes', (tester) async {
      for (final mode in VisualizerMode.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VisualizerWidget(
                mode: mode,
                isPlaying: true,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(VisualizerWidget), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(VisualizerWidget), findsOneWidget);
      }
    });
  });
}
