import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class EqualizerBand {
  final int index;
  final int centerFreqHz;
  final int level; // in millibels (-1500 to 1500)
  final int minLevel;
  final int maxLevel;

  const EqualizerBand({
    required this.index,
    required this.centerFreqHz,
    required this.level,
    required this.minLevel,
    required this.maxLevel,
  });

  String get formattedFreq {
    if (centerFreqHz >= 1000) {
      final khz = (centerFreqHz / 1000).toStringAsFixed(1).replaceAll('.0', '');
      return '${khz}k';
    }
    return '$centerFreqHz';
  }

  String get formattedDb {
    final db = (level / 100).round();
    return db >= 0 ? '+$db dB' : '$db dB';
  }

  EqualizerBand copyWith({int? level}) {
    return EqualizerBand(
      index: index,
      centerFreqHz: centerFreqHz,
      level: level ?? this.level,
      minLevel: minLevel,
      maxLevel: maxLevel,
    );
  }
}

class EqualizerState {
  final bool isSupported;
  final bool isEnabled;
  final int bassBoostStrength; // 0 to 1000
  final bool isBassBoostSupported;
  final List<EqualizerBand> bands;
  final List<String> presets;
  final int? selectedPresetIndex;
  final String? errorMessage;

  const EqualizerState({
    this.isSupported = true,
    this.isEnabled = false,
    this.bassBoostStrength = 0,
    this.isBassBoostSupported = true,
    this.bands = const [],
    this.presets = const [],
    this.selectedPresetIndex,
    this.errorMessage,
  });

  EqualizerState copyWith({
    bool? isSupported,
    bool? isEnabled,
    int? bassBoostStrength,
    bool? isBassBoostSupported,
    List<EqualizerBand>? bands,
    List<String>? presets,
    int? selectedPresetIndex,
    String? errorMessage,
    bool clearSelectedPreset = false,
  }) {
    return EqualizerState(
      isSupported: isSupported ?? this.isSupported,
      isEnabled: isEnabled ?? this.isEnabled,
      bassBoostStrength: bassBoostStrength ?? this.bassBoostStrength,
      isBassBoostSupported: isBassBoostSupported ?? this.isBassBoostSupported,
      bands: bands ?? this.bands,
      presets: presets ?? this.presets,
      selectedPresetIndex: clearSelectedPreset
          ? null
          : (selectedPresetIndex ?? this.selectedPresetIndex),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class EqualizerController extends ValueNotifier<EqualizerState> {
  static const MethodChannel _channel = MethodChannel('com.sunzara.app/audio_effects');

  int? _currentSessionId;

  EqualizerController() : super(const EqualizerState());

  EqualizerState get state => value;
  set state(EqualizerState newState) => value = newState;

  /// Initializes equalizer and bassboost for the given audio session ID
  Future<void> initAudioSession(int? audioSessionId) async {
    if (audioSessionId == null || audioSessionId == _currentSessionId) return;
    _currentSessionId = audioSessionId;

    try {
      final dynamic result = await _channel.invokeMethod('initEffects', {
        'audioSessionId': audioSessionId,
      });

      if (result is Map) {
        final supported = result['supported'] as bool? ?? false;
        if (!supported) {
          state = state.copyWith(
            isSupported: false,
            errorMessage: 'Equalizer is not supported on this device.',
          );
          return;
        }

        final minLevel = (result['minLevel'] as num?)?.toInt() ?? -1500;
        final maxLevel = (result['maxLevel'] as num?)?.toInt() ?? 1500;
        final bassSupported = result['bassBoostSupported'] as bool? ?? false;

        final rawBands = List<Map>.from(result['bands'] as List? ?? []);
        final parsedBands = rawBands.map((b) {
          return EqualizerBand(
            index: (b['index'] as num).toInt(),
            centerFreqHz: (b['centerFreqHz'] as num).toInt(),
            level: (b['currentLevel'] as num).toInt(),
            minLevel: minLevel,
            maxLevel: maxLevel,
          );
        }).toList();

        final rawPresets = List<String>.from(result['presets'] as List? ?? []);

        state = state.copyWith(
          isSupported: true,
          isBassBoostSupported: bassSupported,
          bands: parsedBands,
          presets: rawPresets,
          errorMessage: null,
        );
      }
    } on MissingPluginException {
      // In testing or non-Android environment, provide default 5-band layout
      _initFallbackBands();
    } catch (e) {
      state = state.copyWith(
        isSupported: false,
        errorMessage: 'Equalizer initialization error: ${e.toString()}',
      );
    }
  }

  void _initFallbackBands() {
    const freqs = [60, 230, 910, 3600, 14000];
    final defaultBands = freqs.asMap().entries.map((e) {
      return EqualizerBand(
        index: e.key,
        centerFreqHz: e.value,
        level: 0,
        minLevel: -1500,
        maxLevel: 1500,
      );
    }).toList();

    state = state.copyWith(
      isSupported: true,
      bands: defaultBands,
      presets: ['Normal', 'Rock', 'Pop', 'Classical', 'Jazz', 'Electronic', 'Vocal', 'Bass Boost'],
    );
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setEnabled', {'enabled': enabled});
    } catch (_) {}
    state = state.copyWith(isEnabled: enabled);
  }

  Future<void> setBandLevel(int bandIndex, int levelMillibels) async {
    final updatedBands = List<EqualizerBand>.from(state.bands);
    if (bandIndex >= 0 && bandIndex < updatedBands.length) {
      updatedBands[bandIndex] = updatedBands[bandIndex].copyWith(level: levelMillibels);
      state = state.copyWith(
        bands: updatedBands,
        clearSelectedPreset: true, // Manual adjustment marks preset as custom
      );

      try {
        await _channel.invokeMethod('setBandLevel', {
          'band': bandIndex,
          'level': levelMillibels,
        });
      } catch (_) {}
    }
  }

  Future<void> setBassBoost(int strength) async {
    state = state.copyWith(bassBoostStrength: strength);
    try {
      await _channel.invokeMethod('setBassBoost', {'strength': strength});
    } catch (_) {}
  }

  Future<void> usePreset(int presetIndex) async {
    if (presetIndex < 0 || presetIndex >= state.presets.length) return;

    try {
      await _channel.invokeMethod('usePreset', {'presetIndex': presetIndex});
    } catch (_) {}

    state = state.copyWith(selectedPresetIndex: presetIndex);
  }

  Future<void> release() async {
    try {
      await _channel.invokeMethod('release');
    } catch (_) {}
  }
}
