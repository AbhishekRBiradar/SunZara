import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../audio/presentation/playback_controller.dart';
import '../presentation/widgets/voice_search_sheet.dart';

class VoiceSearchUnavailableException implements Exception {
  final String message;
  const VoiceSearchUnavailableException(this.message);
}

/// Bridges Flutter search screens to an in-app SunZara voice overlay backed by
/// Android's headless SpeechRecognizer (with Intent dialog fallback if unavailable).
class VoiceSearchService {
  static final VoiceSearchService instance = VoiceSearchService._internal();
  static const MethodChannel _channel = MethodChannel('com.sunzara.app/voice_search');
  static const EventChannel _eventsChannel = EventChannel('com.sunzara.app/voice_search_events');

  VoiceSearchService._internal();

  /// Optional test override so widget tests can mock spoken transcripts cleanly.
  @visibleForTesting
  Future<String?> Function({String? prompt})? testRecognizer;

  Stream<VoiceSessionEvent> get _nativeEvents => _eventsChannel
      .receiveBroadcastStream()
      .map(VoiceSessionEvent.fromMap);

  /// Pauses active playback if playing, launches the themed in-app voice command UI,
  /// and returns the recognized song query or null if cancelled.
  Future<String?> listenForQuery({
    BuildContext? context,
    PlaybackController? playbackController,
    String prompt = 'Say a song or artist name',
  }) async {
    if (playbackController != null && playbackController.state.isPlaying) {
      await playbackController.togglePlayPause();
    }

    if (testRecognizer != null) {
      final spoken = await testRecognizer!(prompt: prompt);
      final trimmed = spoken?.trim();
      return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    }

    if (context != null && context.mounted) {
      final inAppAvailable = await _isInAppVoiceAvailable();
      if (inAppAvailable) {
        final micStatus = await Permission.microphone.request();
        if (!micStatus.isGranted) {
          throw const VoiceSearchUnavailableException(
            'Microphone permission is required for voice search.',
          );
        }
        if (!context.mounted) return null;

        final result = await showModalBottomSheet<String?>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => VoiceSearchSheet(
            events: _nativeEvents,
            prompt: prompt,
            onStartListening: () async {
              return (await _channel.invokeMethod<bool>('startInAppVoice')) ?? false;
            },
            onStopListening: () async {
              try {
                await _channel.invokeMethod<bool>('stopInAppVoice');
              } catch (_) {}
            },
          ),
        );
        final trimmed = result?.trim();
        return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
      }
    }

    try {
      final result = await _channel.invokeMethod<String>(
        'startVoiceSearch',
        {'prompt': prompt},
      );
      final trimmed = result?.trim();
      return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    } on PlatformException catch (e) {
      if (e.code == 'UNAVAILABLE') {
        throw const VoiceSearchUnavailableException(
          'Voice search is not available on this device.',
        );
      }
      return null;
    }
  }

  Future<bool> _isInAppVoiceAvailable() async {
    try {
      return (await _channel.invokeMethod<bool>('isInAppVoiceAvailable')) ?? false;
    } catch (_) {
      return false;
    }
  }
}
