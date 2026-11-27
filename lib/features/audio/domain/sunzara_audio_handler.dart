import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/models/song.dart';
import 'local_stream_proxy.dart';
import 'youtube_stream_service.dart';

class SunZaraAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer(
    handleInterruptions: false,
    audioLoadConfiguration: const AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: Duration(seconds: 20),
        maxBufferDuration: Duration(seconds: 60),
        bufferForPlaybackDuration: Duration(milliseconds: 1200),
        bufferForPlaybackAfterRebufferDuration: Duration(seconds: 2),
        backBufferDuration: Duration(seconds: 15),
      ),
    ),
  );

  bool _playInterrupted = false;
  bool _userExplicitlyPaused = true;
  int _setSongGeneration = 0;

  Future<void> Function()? onNextRequested;
  Future<void> Function()? onPreviousRequested;
  Future<void> Function()? onPlayRequested;
  Future<void> Function()? onPauseRequested;
  void Function(String message)? onPlaybackError;

  AudioPlayer get player => _player;
  int? get audioSessionId => _player.androidAudioSessionId;

  SunZaraAudioHandler() {
    _initInitialState();
    _initAudioSession();
    _broadcastPlayerState();
    unawaited(LocalStreamProxy.instance.ensureStarted());
    unawaited(YouTubeStreamService.instance.initDiskCache());
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
      if (_player.playing) {
        _userExplicitlyPaused = true;
        _playInterrupted = false;
        pause();
      }
    });

    // Handle audio interruptions (incoming phone calls, other media apps)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(0.5);
            break;
          case AudioInterruptionType.pause:
            if (_player.playing && !_userExplicitlyPaused) {
              _playInterrupted = true;
              unawaited(_player.pause().then((_) => _broadcastCurrentState()));
            } else {
              _playInterrupted = false;
            }
            break;
          case AudioInterruptionType.unknown:
            // Permanent focus loss (AUDIOFOCUS_LOSS): stay paused rather than auto-resuming.
            _playInterrupted = false;
            _userExplicitlyPaused = true;
            if (_player.playing) {
              unawaited(_player.pause().then((_) => _broadcastCurrentState()));
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
            _playInterrupted = false;
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

  MediaItem _buildMediaItem(Song song) {
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

    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: Duration(milliseconds: song.durationMs),
      artUri: artUri,
      displayTitle: song.title,
      displaySubtitle: song.artist,
      displayDescription: song.album,
    );
  }

  /// Sets restored song metadata without performing network resolution or buffering on bootup
  void setRestoredMetadata(Song song, {Duration? position}) {
    _userExplicitlyPaused = true;
    _playInterrupted = false;
    mediaItem.add(_buildMediaItem(song));
    playbackState.add(playbackState.value.copyWith(
      controls: const [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
      ],
      androidCompactActionIndices: const [0, 1, 2],
      processingState: AudioProcessingState.ready,
      playing: false,
      updatePosition: position ?? Duration.zero,
    ));
  }

  /// Sets active song and prepares audio source
  Future<void> setSong(Song song, {bool autoPlay = true, Duration? startPosition}) async {
    final gen = ++_setSongGeneration;
    _userExplicitlyPaused = !autoPlay;
    _playInterrupted = false;

    mediaItem.add(_buildMediaItem(song));

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

    debugPrint('SunZaraAudioHandler.setSong: id=${song.id}, title=${song.title}, artist=${song.artist}, isOnline=${song.isOnline}, filePath=${song.filePath}');
    try {
      if (song.filePath.isNotEmpty) {
        String playUri = song.filePath;

        // Resolve YouTube stream candidates if online track
        List<String> onlineCandidates = const [];
        String querySource = song.filePath;
        if (song.isOnline) {
          playbackState.add(playbackState.value.copyWith(
            processingState: AudioProcessingState.buffering,
          ));
          if (querySource.isEmpty ||
              querySource.startsWith('http://') ||
              querySource.startsWith('https://')) {
            querySource = 'yt:search:${song.title} ${song.artist}';
          }
          debugPrint('SunZaraAudioHandler: resolving online track "$querySource"');
          onlineCandidates =
              await YouTubeStreamService.instance.resolveAudioStreamCandidates(querySource);
          if (gen != _setSongGeneration) return;
          if (onlineCandidates.isNotEmpty) {
            playUri = onlineCandidates.first;
            debugPrint('SunZaraAudioHandler: got ${onlineCandidates.length} candidate URL(s)');
          }
        }

        if (song.isOnline) {
          var loaded = await _tryPrepareCandidates(onlineCandidates, startPosition, gen);
          if (gen != _setSongGeneration) return;
          if (!loaded) {
            final freshSource = song.filePath.startsWith('yt:video:')
                ? song.filePath
                : 'yt:search:${song.title} ${song.artist}';
            final freshCandidates = await YouTubeStreamService.instance
                .resolveAudioStreamCandidates(freshSource, forceRefresh: true);
            if (gen != _setSongGeneration) return;
            loaded = await _tryPrepareCandidates(freshCandidates, startPosition, gen);
            if (gen != _setSongGeneration) return;
          }
          if (!loaded) {
            debugPrint('SunZaraAudioHandler: failed all stream candidates for ${song.title}');
            playbackState.add(playbackState.value.copyWith(
              processingState: AudioProcessingState.idle,
              playing: false,
            ));
            onPlaybackError?.call('Could not play "${song.title}". Try another result.');
            return;
          }
          if (_player.duration != null && _player.duration! > Duration.zero) {
            mediaItem.add(mediaItem.value?.copyWith(duration: _player.duration));
          }
        } else if (playUri.startsWith('http://') || playUri.startsWith('https://')) {
          await _player.setUrl(playUri, initialPosition: startPosition);
          if (_player.duration != null && _player.duration! > Duration.zero) {
            mediaItem.add(mediaItem.value?.copyWith(duration: _player.duration));
          }
        } else if (playUri.startsWith('content://')) {
          // MediaStore can return a content URI when Android restricts access
          // to the underlying filesystem path. Open it as a URI source rather
          // than passing it to setFilePath, which only accepts file paths.
          await _player.setAudioSource(
            AudioSource.uri(Uri.parse(playUri)),
            initialPosition: startPosition,
          );
        } else {
          await _player.setFilePath(playUri, initialPosition: startPosition);
        }
        if (gen != _setSongGeneration) return;
        if (autoPlay) {
          // Do not await _player.play(): just_audio resolves play() only after pause/completion.
          unawaited(_player.play());
        }
      }
    } catch (e, stack) {
      debugPrint('SunZaraAudioHandler error setting song: $e\n$stack');
      onPlaybackError?.call('Playback error for "${song.title}".');
    }

    _broadcastCurrentState();
  }

  /// Routes YouTube URLs through LocalStreamProxy (bounded 512KB Range chunks
  /// required by YouTube's CDN) with direct playback as fallback.
  Future<bool> _tryPrepareCandidates(
    List<String> urls,
    Duration? startPosition,
    int gen,
  ) async {
    await LocalStreamProxy.instance.ensureStarted();
    for (final url in urls) {
      if (gen != _setSongGeneration) return false;
      try {
        final proxyUri = LocalStreamProxy.instance.registerUrl(url);
        await _player.setUrl(proxyUri, initialPosition: startPosition);
        return true;
      } catch (proxyErr) {
        debugPrint('SunZaraAudioHandler proxy setUrl failed: $proxyErr, trying direct');
        if (gen != _setSongGeneration) return false;
        try {
          final hdrs = YouTubeStreamService.headersForUrl(url);
          await _player.setUrl(
            url,
            headers: hdrs.isEmpty ? null : hdrs,
            initialPosition: startPosition,
          );
          return true;
        } catch (directErr) {
          debugPrint('SunZaraAudioHandler direct setUrl failed: $directErr');
        }
      }
    }
    return false;
  }

  @override
  Future<void> play() async {
    _userExplicitlyPaused = false;
    _playInterrupted = false;
    if (onPlayRequested != null) {
      await onPlayRequested!();
    } else {
      unawaited(_player.play());
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
