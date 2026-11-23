import 'dart:math';
import '../../../core/models/playback_context.dart';
import '../../../core/models/song.dart';

/// Intelligent Shuffle Engine for SunZara
/// Standalone pure Dart class with no Flutter imports.
/// Implements the shuffle-bag algorithm to prevent unwanted automatic repetition.
class ShuffleEngine {
  final Random _random;

  PlaybackContext? _context;
  List<Song> _sourceTracks = [];
  List<Song> _remainingPool = [];
  final List<String> _playedSongIds = [];
  Song? _currentSong;
  Song? _lastCycleFinalSong;

  bool isShuffleEnabled;
  RepeatMode repeatMode;
  int _currentIndex = -1;

  ShuffleEngine({
    this.isShuffleEnabled = true,
    this.repeatMode = RepeatMode.off,
    Random? random,
  }) : _random = random ?? Random();

  // Getters
  PlaybackContext? get context => _context;
  Song? get currentSong => _currentSong;
  List<Song> get sourceTracks => List.unmodifiable(_sourceTracks);
  List<Song> get remainingPool => List.unmodifiable(_remainingPool);
  List<String> get playedSongIds => List.unmodifiable(_playedSongIds);
  int get currentIndex => _currentIndex;

  /// Initializes playback for a given context and track collection.
  void initializeContext(
    PlaybackContext context,
    List<Song> tracks, {
    Song? startSong,
    bool? shuffleEnabled,
  }) {
    _context = context;
    _sourceTracks = List.from(tracks);
    _playedSongIds.clear();
    _lastCycleFinalSong = null;

    if (shuffleEnabled != null) {
      isShuffleEnabled = shuffleEnabled;
    }

    if (_sourceTracks.isEmpty) {
      _currentSong = null;
      _currentIndex = -1;
      _remainingPool.clear();
      return;
    }

    final initialSong = startSong ?? _sourceTracks.first;
    _currentSong = initialSong;
    _currentIndex = _sourceTracks.indexWhere((s) => s.id == initialSong.id);
    if (_currentIndex == -1) _currentIndex = 0;

    _generateNewCycle(startingSong: initialSong);
  }

  /// Generates a new shuffle-bag cycle using Fisher-Yates algorithm.
  void _generateNewCycle({Song? startingSong}) {
    if (_sourceTracks.isEmpty) {
      _remainingPool.clear();
      return;
    }

    if (!isShuffleEnabled) {
      // Sequential playback
      _remainingPool = List.from(_sourceTracks);
      return;
    }

    final pool = List<Song>.from(_sourceTracks);

    if (startingSong != null) {
      // Place starting track first, randomize the remaining
      pool.removeWhere((s) => s.id == startingSong.id);
      _fisherYatesShuffle(pool);
      _remainingPool = [startingSong, ...pool];
    } else {
      _fisherYatesShuffle(pool);

      // Avoid choosing previous cycle's final track as the first track when alternatives exist
      if (pool.length > 1 &&
          _lastCycleFinalSong != null &&
          pool.first.id == _lastCycleFinalSong!.id) {
        // Swap first with second
        final temp = pool[0];
        pool[0] = pool[1];
        pool[1] = temp;
      }
      _remainingPool = pool;
    }
  }

  /// Standard in-place Fisher-Yates shuffle
  void _fisherYatesShuffle(List<Song> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  /// Advances to the next track according to shuffle, repeat, and cycle state.
  Song? nextTrack() {
    if (_sourceTracks.isEmpty) return null;

    if (repeatMode == RepeatMode.one && _currentSong != null) {
      return _currentSong;
    }

    if (!isShuffleEnabled) {
      return _nextSequential();
    }

    return _nextShuffled();
  }

  Song? _nextSequential() {
    if (_currentIndex < _sourceTracks.length - 1) {
      _currentIndex++;
      _currentSong = _sourceTracks[_currentIndex];
      _recordPlayed(_currentSong!);
      return _currentSong;
    }

    // End of sequential list reached
    if (repeatMode == RepeatMode.all) {
      _currentIndex = 0;
      _currentSong = _sourceTracks[_currentIndex];
      _recordPlayed(_currentSong!);
      return _currentSong;
    }

    return null;
  }

  Song? _nextShuffled() {
    if (_currentSong != null) {
      _recordPlayed(_currentSong!);
      // Remove current song from remaining pool if still there
      _remainingPool.removeWhere((s) => s.id == _currentSong!.id);
    }

    if (_remainingPool.isNotEmpty) {
      _currentSong = _remainingPool.removeAt(0);
      _currentIndex = _sourceTracks.indexWhere((s) => s.id == _currentSong!.id);
      return _currentSong;
    }

    // Pool is exhausted: Cycle complete
    if (repeatMode == RepeatMode.all) {
      _lastCycleFinalSong = _currentSong;
      _generateNewCycle();
      if (_remainingPool.isNotEmpty) {
        _currentSong = _remainingPool.removeAt(0);
        _currentIndex = _sourceTracks.indexWhere((s) => s.id == _currentSong!.id);
        return _currentSong;
      }
    }

    return null;
  }

  /// Retreats to the previous track according to the played history or sequential index.
  Song? previousTrack() {
    if (_sourceTracks.isEmpty) return null;

    if (repeatMode == RepeatMode.one && _currentSong != null) {
      return _currentSong;
    }

    if (!isShuffleEnabled) {
      if (_currentIndex > 0) {
        _currentIndex--;
        _currentSong = _sourceTracks[_currentIndex];
        return _currentSong;
      } else if (repeatMode == RepeatMode.all) {
        _currentIndex = _sourceTracks.length - 1;
        _currentSong = _sourceTracks[_currentIndex];
        return _currentSong;
      }
      return _currentSong;
    }

    // In shuffle mode: pop from played history if available
    if (_playedSongIds.length > 1) {
      // Remove current song
      _playedSongIds.removeLast();
      final prevSongId = _playedSongIds.last;
      final prevSong = _sourceTracks.firstWhere(
        (s) => s.id == prevSongId,
        orElse: () => _sourceTracks.first,
      );
      if (_currentSong != null) {
        // Put current back in remaining pool at front
        _remainingPool.insert(0, _currentSong!);
      }
      _currentSong = prevSong;
      _currentIndex = _sourceTracks.indexWhere((s) => s.id == prevSong.id);
      return _currentSong;
    }

    return _currentSong;
  }

  void _recordPlayed(Song song) {
    if (_playedSongIds.isEmpty || _playedSongIds.last != song.id) {
      _playedSongIds.add(song.id);
    }
  }

  /// Sets Repeat Mode (off, all, one)
  void setRepeatMode(RepeatMode mode) {
    repeatMode = mode;
  }

  /// Toggles Auto Shuffle ON/OFF
  void toggleShuffle([bool? enable]) {
    isShuffleEnabled = enable ?? !isShuffleEnabled;

    if (_sourceTracks.isEmpty) return;

    if (isShuffleEnabled) {
      // Re-randomize remaining tracks avoiding repetition
      final unplayed = _sourceTracks
          .where((s) => !_playedSongIds.contains(s.id) && s.id != _currentSong?.id)
          .toList();
      _fisherYatesShuffle(unplayed);
      _remainingPool = unplayed;
    } else {
      // Revert to sequential from current position
      if (_currentSong != null) {
        _currentIndex = _sourceTracks.indexWhere((s) => s.id == _currentSong!.id);
      }
      _remainingPool.clear();
    }
  }

  /// Handles track dynamically added to library/context
  void addTrack(Song song) {
    _sourceTracks.add(song);
    if (isShuffleEnabled) {
      // Insert randomly in remaining pool
      final insertIndex = _remainingPool.isEmpty ? 0 : _random.nextInt(_remainingPool.length + 1);
      _remainingPool.insert(insertIndex, song);
    }
  }

  /// Handles track removed during playback
  void removeTrack(String songId) {
    _sourceTracks.removeWhere((s) => s.id == songId);
    _remainingPool.removeWhere((s) => s.id == songId);
    _playedSongIds.removeWhere((id) => id == songId);

    if (_currentSong?.id == songId) {
      _currentSong = nextTrack();
    }
  }

  /// Returns upcoming tracks in this shuffle cycle (for queue previews)
  List<Song> getUpcomingCycleTracks() {
    if (!isShuffleEnabled) {
      if (_currentIndex >= 0 && _currentIndex < _sourceTracks.length - 1) {
        return _sourceTracks.sublist(_currentIndex + 1);
      }
      return [];
    }
    return List.unmodifiable(_remainingPool);
  }

  /// Exports state for persistence
  Map<String, dynamic> exportState() {
    return {
      'context': _context?.toMap(),
      'sourceSongIds': _sourceTracks.map((s) => s.id).toList(),
      'remainingSongIds': _remainingPool.map((s) => s.id).toList(),
      'playedSongIds': List<String>.from(_playedSongIds),
      'currentSongId': _currentSong?.id,
      'isShuffleEnabled': isShuffleEnabled,
      'repeatMode': repeatMode.name,
      'currentIndex': _currentIndex,
    };
  }

  /// Restores state from persistence
  void restoreState({
    required Map<String, dynamic> state,
    required List<Song> allAvailableSongs,
  }) {
    final songMap = {for (final s in allAvailableSongs) s.id: s};

    if (state['context'] != null) {
      _context = PlaybackContext.fromMap(state['context'] as Map<String, dynamic>);
    }

    final sourceIds = List<String>.from(state['sourceSongIds'] ?? []);
    _sourceTracks = sourceIds.map((id) => songMap[id]).whereType<Song>().toList();

    final remainingIds = List<String>.from(state['remainingSongIds'] ?? []);
    _remainingPool = remainingIds.map((id) => songMap[id]).whereType<Song>().toList();

    _playedSongIds.clear();
    _playedSongIds.addAll(List<String>.from(state['playedSongIds'] ?? []));

    final currentId = state['currentSongId'] as String?;
    _currentSong = currentId != null ? songMap[currentId] : null;

    isShuffleEnabled = (state['isShuffleEnabled'] as bool?) ?? true;
    repeatMode = RepeatMode.values.firstWhere(
      (m) => m.name == state['repeatMode'],
      orElse: () => RepeatMode.off,
    );
    _currentIndex = (state['currentIndex'] as int?) ?? -1;
  }
}
