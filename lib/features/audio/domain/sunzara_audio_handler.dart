import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/models/song.dart';

class SunZaraAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  bool _playInterrupted = false;
  bool _userExplicitlyPaused = true;

  Future<void> Function()? onNextRequested;
  Future<void> Function()? onPreviousRequested;
  Future<void> Function()? onPlayRequested;
  Future<void> Function()? onPauseRequested;

  AudioPlayer get player => _player;
  int? get audioSessionId => _player.androidAudioSessionId;

  SunZaraAudioHandler() {
    _initInitialState();
    _initAudioSession();
    _broadcastPlayerState();
  }

  void _initInitialState() {
    playbackState.add(PlaybackState(
      controls: const [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Pause when headphones/bluetooth disconnect (BECOMING_NOISY)
    session.becomingNoisyEventStream.listen((_) {
      _userExplicitlyPaused = true;
      _playInterrupted = false;
      pause();
    });

    // Handle audio interruptions (incoming phone calls, other media apps)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(0.5);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            if (_player.playing && !_userExplicitlyPaused) {
              _playInterrupted = true;
              _player.pause();
            } else {
              _playInterrupted = false;
            }
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            // Only resume if we were playing and interrupted, and user didn't explicitly pause
            if (_playInterrupted && !_userExplicitlyPaused) {
              _playInterrupted = false;
              play();
            }
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });
  }

  void _broadcastPlayerState() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      _broadcastCurrentState();
    });

    _player.playerStateStream.listen((PlayerState state) {
      _broadcastCurrentState();
    });
  }

  void _broadcastCurrentState() {
    final playing = _player.playing;
    final procState = _player.processingState;

    AudioProcessingState audioProcessingState;
    switch (procState) {
      case ProcessingState.idle:
        audioProcessingState = mediaItem.value != null
            ? AudioProcessingState.ready
            : AudioProcessingState.idle;
        break;
      case ProcessingState.loading:
        audioProcessingState = AudioProcessingState.loading;
        break;
      case ProcessingState.buffering:
        audioProcessingState = AudioProcessingState.buffering;
        break;
      case ProcessingState.ready:
        audioProcessingState = AudioProcessingState.ready;
        break;
      case ProcessingState.completed:
        audioProcessingState = AudioProcessingState.completed;
        break;
    }

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: audioProcessingState,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    ));
  }

  /// Sets active song and prepares audio source
  Future<void> setSong(Song song, {bool autoPlay = true, Duration? startPosition}) async {
    _userExplicitlyPaused = !autoPlay;
    _playInterrupted = false;

    Uri? artUri;
    if (song.artworkUri != null && song.artworkUri!.isNotEmpty) {
      if (song.artworkUri!.startsWith('content://') ||
          song.artworkUri!.startsWith('file://') ||
          song.artworkUri!.startsWith('http')) {
        artUri = Uri.tryParse(song.artworkUri!);
      } else {
        artUri = Uri.file(song.artworkUri!);
      }
    }

    mediaItem.add(MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: Duration(milliseconds: song.durationMs),
      artUri: artUri,
      displayTitle: song.title,
      displaySubtitle: song.artist,
      displayDescription: song.album,
    ));

    // Immediately notify system of playback update
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (autoPlay) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: AudioProcessingState.loading,
      playing: autoPlay,
      updatePosition: startPosition ?? Duration.zero,
    ));

    try {
      if (song.filePath.isNotEmpty) {
        await _player.setFilePath(song.filePath, initialPosition: startPosition);
        if (autoPlay) {
          await _player.play();
        }
      }
    } catch (e) {
      // Handle inaccessible/unreadable audio files gracefully
    }

    _broadcastCurrentState();
  }

  @override
  Future<void> play() async {
    _userExplicitlyPaused = false;
    _playInterrupted = false;
    if (onPlayRequested != null) {
      await onPlayRequested!();
    } else {
      await _player.play();
    }
    _broadcastCurrentState();
  }

  @override
  Future<void> pause() async {
    _userExplicitlyPaused = true;
    _playInterrupted = false;
    if (onPauseRequested != null) {
      await onPauseRequested!();
    } else {
      await _player.pause();
    }
    _broadcastCurrentState();
  }

  @override
  Future<void> stop() async {
    _userExplicitlyPaused = true;
    _playInterrupted = false;
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
    await super.stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _broadcastCurrentState();
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> skipToNext() async {
    if (onNextRequested != null) {
      await onNextRequested!();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (onPreviousRequested != null) {
      await onPreviousRequested!();
    }
  }

  Future<void> release() async {
    await _player.dispose();
  }
}
