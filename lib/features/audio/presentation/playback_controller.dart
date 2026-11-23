import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/models/playback_context.dart';
import '../../../core/models/song.dart';
import '../../library/domain/music_repository.dart';
import '../../queue/domain/queue_manager.dart';
import '../domain/playback_state_model.dart';
import '../domain/sunzara_audio_handler.dart';

// Riverpod Provider
final playbackControllerProvider = Provider<PlaybackController>((ref) {
  throw UnimplementedError('Initialized via ProviderScope overrides in main.dart');
});

class PlaybackController extends ValueNotifier<PlaybackStateModel> {
  final SunZaraAudioHandler _audioHandler;
  final QueueManager _queueManager;
  final MusicRepository _repository;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;

  PlaybackController({
    required this._audioHandler,
    required this._queueManager,
    required this._repository,
  }) : super(const PlaybackStateModel()) {
    _initListeners();
  }

  PlaybackStateModel get state => value;
  set state(PlaybackStateModel newState) => value = newState;

  void _initListeners() {
    // Media button next/previous/play/pause from notification/lock-screen
    _audioHandler.onNextRequested = () => next();
    _audioHandler.onPreviousRequested = () => previous();
    _audioHandler.onPlayRequested = () async {
      if (state.currentSong == null && _queueManager.fullUpcomingQueue.isNotEmpty) {
        await next();
      } else {
        await _audioHandler.player.play();
      }
    };
    _audioHandler.onPauseRequested = () async {
      await _audioHandler.player.pause();
    };

    // Player state (playing, buffering, completed)
    _playerStateSub = _audioHandler.player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final isBuffering = playerState.processingState == ProcessingState.buffering ||
          playerState.processingState == ProcessingState.loading;

      state = state.copyWith(
        isPlaying: isPlaying,
        isBuffering: isBuffering,
        audioSessionId: _audioHandler.audioSessionId,
      );

      // Handle track completion
      if (playerState.processingState == ProcessingState.completed) {
        next();
      }
    });

    // Position stream
    _positionSub = _audioHandler.player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    // Duration stream
    _durationSub = _audioHandler.player.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });
  }

  /// Play Now:
  /// Starts selected track immediately, updates playback context,
  /// reinitializes shuffle engine and automatic pool, while preserving the manual queue.
  Future<void> playSong(
    Song song,
    PlaybackContext context,
    List<Song> contextTracks, {
    bool? shuffleEnabled,
  }) async {
    final useShuffle = shuffleEnabled ?? state.isShuffleEnabled;

    _queueManager.playNow(
      song: song,
      context: context,
      contextTracks: contextTracks,
      shuffleEnabled: useShuffle,
    );

    _syncStateFromQueueManager();

    await _audioHandler.setSong(song, autoPlay: true);
    await _repository.recordSongPlayed(song.id);
    _persistCurrentState();
  }

  /// Toggle Play/Pause
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _audioHandler.pause();
    } else {
      if (state.currentSong == null && _queueManager.fullUpcomingQueue.isNotEmpty) {
        await next();
      } else {
        await _audioHandler.play();
      }
    }
  }

  /// Next track according to queue priority
  Future<void> next({bool forceNext = false}) async {
    final nextSong = _queueManager.moveToNext(forceNext: forceNext);
    if (nextSong != null) {
      _syncStateFromQueueManager();
      await _audioHandler.setSong(nextSong, autoPlay: true);
      await _repository.recordSongPlayed(nextSong.id);
      _persistCurrentState();
    } else {
      // Reached end of queue
      await _audioHandler.stop();
      state = state.copyWith(
        clearCurrentSong: true,
        isPlaying: false,
        position: Duration.zero,
      );
      _persistCurrentState();
    }
  }

  /// Previous track:
  /// "If more than 3 seconds have played, restart current track.
  /// Otherwise play previous track according to active queue."
  Future<void> previous() async {
    if (state.position.inSeconds > 3) {
      await _audioHandler.seek(Duration.zero);
      return;
    }

    final prevSong = _queueManager.moveToPrevious();
    if (prevSong != null) {
      _syncStateFromQueueManager();
      await _audioHandler.setSong(prevSong, autoPlay: true);
      _persistCurrentState();
    } else {
      await _audioHandler.seek(Duration.zero);
    }
  }

  /// Seek to target duration
  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }

  /// Playback speed (0.75x, 1.0x, 1.25x, 1.5x, 2.0x)
  Future<void> setSpeed(double speed) async {
    await _audioHandler.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  /// Toggle Auto Shuffle ON/OFF
  void toggleShuffle() {
    final newShuffle = !state.isShuffleEnabled;
    _queueManager.toggleShuffle(newShuffle);
    _syncStateFromQueueManager();
    _persistCurrentState();
  }

  /// Cycle Repeat Mode: OFF -> ALL -> ONE -> OFF
  void cycleRepeatMode() {
    final nextMode = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    _queueManager.setRepeatMode(nextMode);
    _syncStateFromQueueManager();
    _persistCurrentState();
  }

  /// Play Next (inserts at front of manual queue)
  void playNext(Song song) {
    _queueManager.playNext(song);
    _syncStateFromQueueManager();
    _persistCurrentState();
  }

  /// Add to Queue (appends to manual queue)
  void addToQueue(Song song) {
    _queueManager.addToQueue(song);
    _syncStateFromQueueManager();
    _persistCurrentState();
  }

  /// Drag-and-drop reorder in manual queue
  void reorderManualQueue(int oldIndex, int newIndex) {
    _queueManager.reorderManualQueue(oldIndex, newIndex);
    _syncStateFromQueueManager();
    _persistCurrentState();
  }

  /// Drag-and-drop reorder in automatic pool
  void reorderAutomaticPool(int oldIndex, int newIndex) {
    _queueManager.reorderAutomaticPool(oldIndex, newIndex);
    _syncStateFromQueueManager();
    _persistCurrentState();
  }

  /// Remove item from upcoming queue
  void removeFromQueue(String queueId) {
    _queueManager.removeFromQueue(queueId);
    _syncStateFromQueueManager();
    _persistCurrentState();
  }

  /// Clear upcoming tracks
  void clearUpcoming() {
    _queueManager.clearUpcoming();
    _syncStateFromQueueManager();
    _persistCurrentState();
  }

  /// Play selected track from upcoming queue index
  Future<void> playTrackAtIndex(int combinedIndex) async {
    final song = _queueManager.playTrackAtIndex(combinedIndex);
    if (song != null) {
      _syncStateFromQueueManager();
      await _audioHandler.setSong(song, autoPlay: true);
      await _repository.recordSongPlayed(song.id);
      _persistCurrentState();
    }
  }

  /// Toggle favorite on current song
  Future<void> toggleFavorite() async {
    final current = state.currentSong;
    if (current == null) return;

    final newStatus = !current.isFavorite;
    await _repository.toggleFavorite(current.id, newStatus);
    final updated = current.copyWith(isFavorite: newStatus);

    state = state.copyWith(currentSong: updated);
  }

  /// Restores persisted playback state on app launch (paused by default)
  Future<void> restorePersistedState() async {
    try {
      final savedState = await _repository.getLatestPlaybackState();
      if (savedState == null || savedState.currentSongId == null) return;

      final allSongs = await _repository.getAllSongs();
      final songMap = {for (final s in allSongs) s.id: s};
      final song = songMap[savedState.currentSongId];
      if (song == null) return;

      final manualQueueList = (jsonDecode(savedState.manualQueueJson) as List)
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();

      final automaticPoolList = (jsonDecode(savedState.automaticPoolJson) as List)
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();

      final shuffleState = jsonDecode(savedState.shuffleStateJson) as Map<String, dynamic>;

      _queueManager.restoreState({
        'currentSong': song.toMap(),
        'manualQueue': manualQueueList,
        'automaticPool': automaticPoolList,
        'shuffleEngine': shuffleState,
      }, allSongs);

      final context = PlaybackContext(
        type: PlaybackContextType.values.firstWhere(
          (t) => t.name == savedState.contextType,
          orElse: () => PlaybackContextType.library,
        ),
        id: savedState.contextId,
        name: savedState.contextName,
      );

      final repeat = RepeatMode.values.firstWhere(
        (m) => m.name == savedState.repeatMode,
        orElse: () => RepeatMode.off,
      );

      _queueManager.setRepeatMode(repeat);
      _queueManager.toggleShuffle(savedState.isShuffleEnabled);

      state = state.copyWith(
        currentSong: song,
        isPlaying: false,
        position: Duration(milliseconds: savedState.positionMs),
        duration: Duration(milliseconds: song.durationMs),
        isShuffleEnabled: savedState.isShuffleEnabled,
        repeatMode: repeat,
        context: context,
        manualQueue: _queueManager.manualQueue,
        automaticPool: _queueManager.automaticPool,
      );

      // Prepare audio engine at restored position without auto-playing
      await _audioHandler.setSong(
        song,
        autoPlay: false,
        startPosition: Duration(milliseconds: savedState.positionMs),
      );
    } catch (e) {
      // Safe fallback on corrupt persistence data
    }
  }

  void _syncStateFromQueueManager() {
    state = state.copyWith(
      currentSong: _queueManager.currentSong,
      manualQueue: _queueManager.manualQueue,
      automaticPool: _queueManager.automaticPool,
      isShuffleEnabled: _queueManager.shuffleEngine.isShuffleEnabled,
      repeatMode: _queueManager.shuffleEngine.repeatMode,
      context: _queueManager.shuffleEngine.context ?? state.context,
    );
  }

  void _persistCurrentState() {
    final current = state.currentSong;
    final exportedQueue = _queueManager.exportState();

    _repository.savePlaybackState(
      currentSongId: current?.id,
      positionMs: state.position.inMilliseconds,
      context: state.context,
      isShuffleEnabled: state.isShuffleEnabled,
      repeatMode: state.repeatMode,
      manualQueueJson: jsonEncode(exportedQueue['manualQueue']),
      automaticPoolJson: jsonEncode(exportedQueue['automaticPool']),
      shuffleStateJson: jsonEncode(exportedQueue['shuffleEngine']),
    );
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    super.dispose();
  }
}
