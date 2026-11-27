import '../../../core/models/playback_context.dart';
import '../../../core/models/queue_item.dart';
import '../../../core/models/song.dart';
import 'shuffle_engine.dart';

/// Advanced Queue Manager for SunZara
/// Standalone pure Dart class with no Flutter imports.
/// Enforces two-tier architecture:
/// 1. Manual Queue (User explicit additions)
/// 2. Automatic Shuffle Pool (Engine generated)
/// Priority: Currently Playing -> Manual Queue -> Automatic Shuffle Pool.
class QueueManager {
  final ShuffleEngine _shuffleEngine;

  Song? _currentSong;
  final List<QueueItem> _manualQueue = [];
  final List<QueueItem> _automaticPool = [];
  final List<Song> _history = [];

  int _queueCounter = 0;

  QueueManager({ShuffleEngine? shuffleEngine})
      : _shuffleEngine = shuffleEngine ?? ShuffleEngine();

  // Getters
  ShuffleEngine get shuffleEngine => _shuffleEngine;
  Song? get currentSong => _currentSong;
  List<QueueItem> get manualQueue => List.unmodifiable(_manualQueue);
  List<QueueItem> get automaticPool => List.unmodifiable(_automaticPool);
  List<Song> get history => List.unmodifiable(_history);

  /// Combined upcoming queue for UI display (Manual items first, then Automatic items)
  List<QueueItem> get fullUpcomingQueue => [
        ..._manualQueue,
        ..._automaticPool,
      ];

  /// Peeks the next [count] upcoming songs in queue order for preloading
  List<Song> peekUpcoming({int count = 3}) {
    final result = <Song>[];
    for (final item in fullUpcomingQueue) {
      result.add(item.song);
      if (result.length >= count) break;
    }
    return result;
  }

  String _generateQueueId() {
    _queueCounter++;
    return 'q_${DateTime.now().millisecondsSinceEpoch}_$_queueCounter';
  }

  /// Play Now:
  /// Starts selected track immediately, updates playback context,
  /// reinitializes shuffle engine and automatic pool, while preserving the manual queue.
  void playNow({
    required Song song,
    required PlaybackContext context,
    required List<Song> contextTracks,
    bool shuffleEnabled = true,
  }) {
    if (_currentSong != null) {
      _history.add(_currentSong!);
    }
    _currentSong = song;

    // Initialize shuffle engine with starting song
    _shuffleEngine.initializeContext(
      context,
      contextTracks,
      startSong: song,
      shuffleEnabled: shuffleEnabled,
    );

    _syncAutomaticPoolFromShuffleEngine();
  }

  /// Play Next:
  /// Inserts a selected track immediately after the current song
  /// (i.e. at index 0 of the manual queue).
  void playNext(Song song) {
    final item = QueueItem(
      queueId: _generateQueueId(),
      song: song,
      type: QueueItemType.manual,
    );
    _manualQueue.insert(0, item);
  }

  /// Add to Queue:
  /// Appends the track to the end of the manual queue without interrupting playback.
  void addToQueue(Song song) {
    final item = QueueItem(
      queueId: _generateQueueId(),
      song: song,
      type: QueueItemType.manual,
    );
    _manualQueue.add(item);
  }

  /// Advances playback to the next song.
  /// Priority order:
  /// 1. Repeat ONE mode (repeat current track)
  /// 2. Manual Queue items (in order)
  /// 3. Automatic Shuffle Pool items
  Song? moveToNext({bool forceNext = false}) {
    // If Repeat ONE is active and user didn't force next, repeat current
    if (!forceNext && _shuffleEngine.repeatMode == RepeatMode.one && _currentSong != null) {
      return _currentSong;
    }

    if (_currentSong != null) {
      _history.add(_currentSong!);
    }

    // 1. Check Manual Queue first
    if (_manualQueue.isNotEmpty) {
      final nextManual = _manualQueue.removeAt(0);
      _currentSong = nextManual.song;
      return _currentSong;
    }

    // 2. Check Automatic Pool
    if (_automaticPool.isNotEmpty) {
      final nextAuto = _automaticPool.removeAt(0);
      _currentSong = nextAuto.song;
      return _currentSong;
    }

    // 3. Request next from shuffle engine (handles cycle regeneration / repeat all)
    final engineNext = _shuffleEngine.nextTrack();
    if (engineNext != null) {
      _currentSong = engineNext;
      _syncAutomaticPoolFromShuffleEngine();
      return _currentSong;
    }

    // End of queue reached with no repeat
    _currentSong = null;
    return null;
  }

  /// Retreats playback to the previous song.
  Song? moveToPrevious() {
    if (_shuffleEngine.repeatMode == RepeatMode.one && _currentSong != null) {
      return _currentSong;
    }

    // Pop from local history first if available
    if (_history.isNotEmpty) {
      final prevSong = _history.removeLast();
      if (_currentSong != null) {
        // Re-insert current song into manual queue at front
        _manualQueue.insert(
          0,
          QueueItem(
            queueId: _generateQueueId(),
            song: _currentSong!,
            type: QueueItemType.manual,
          ),
        );
      }
      _currentSong = prevSong;
      return _currentSong;
    }

    // Fall back to shuffle engine previous track
    final enginePrev = _shuffleEngine.previousTrack();
    if (enginePrev != null) {
      _currentSong = enginePrev;
      return _currentSong;
    }

    return _currentSong;
  }

  /// Synchronizes the automatic pool from the shuffle engine's upcoming cycle.
  void _syncAutomaticPoolFromShuffleEngine() {
    _automaticPool.clear();
    final upcoming = _shuffleEngine.getUpcomingCycleTracks();
    for (final song in upcoming) {
      // Don't add current song to upcoming
      if (song.id == _currentSong?.id) continue;
      _automaticPool.add(
        QueueItem(
          queueId: _generateQueueId(),
          song: song,
          type: QueueItemType.automatic,
        ),
      );
    }
  }

  /// Updates cached favorite metadata across active, queued, and history entries.
  void updateSongFavoriteStatus(String songId, bool isFavorite) {
    if (_currentSong?.id == songId) {
      _currentSong = _currentSong!.copyWith(isFavorite: isFavorite);
    }
    for (var i = 0; i < _manualQueue.length; i++) {
      if (_manualQueue[i].song.id == songId) {
        _manualQueue[i] = QueueItem(
          queueId: _manualQueue[i].queueId,
          song: _manualQueue[i].song.copyWith(isFavorite: isFavorite),
          type: _manualQueue[i].type,
        );
      }
    }
    for (var i = 0; i < _automaticPool.length; i++) {
      if (_automaticPool[i].song.id == songId) {
        _automaticPool[i] = QueueItem(
          queueId: _automaticPool[i].queueId,
          song: _automaticPool[i].song.copyWith(isFavorite: isFavorite),
          type: _automaticPool[i].type,
        );
      }
    }
    for (var i = 0; i < _history.length; i++) {
      if (_history[i].id == songId) {
        _history[i] = _history[i].copyWith(isFavorite: isFavorite);
      }
    }
  }

  /// Drag-and-drop reordering within manual queue
  void reorderManualQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _manualQueue.length) return;
    if (newIndex < 0 || newIndex > _manualQueue.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _manualQueue.removeAt(oldIndex);
    _manualQueue.insert(newIndex, item);
  }

  /// Drag-and-drop reordering within automatic pool
  void reorderAutomaticPool(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _automaticPool.length) return;
    if (newIndex < 0 || newIndex > _automaticPool.length) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _automaticPool.removeAt(oldIndex);
    _automaticPool.insert(newIndex, item);
  }

  /// Removes an individual item from either queue by its unique queueId
  bool removeFromQueue(String queueId) {
    final manualIndex = _manualQueue.indexWhere((item) => item.queueId == queueId);
    if (manualIndex != -1) {
      _manualQueue.removeAt(manualIndex);
      return true;
    }

    final autoIndex = _automaticPool.indexWhere((item) => item.queueId == queueId);
    if (autoIndex != -1) {
      _automaticPool.removeAt(autoIndex);
      return true;
    }

    return false;
  }

  /// Clears all upcoming tracks (both manual and automatic)
  void clearUpcoming() {
    _manualQueue.clear();
    _automaticPool.clear();
  }

  /// Plays a selected track directly from the upcoming queue at [combinedIndex].
  Song? playTrackAtIndex(int combinedIndex) {
    if (combinedIndex < 0 || combinedIndex >= fullUpcomingQueue.length) return null;

    if (combinedIndex < _manualQueue.length) {
      // Selected from manual queue
      final item = _manualQueue.removeAt(combinedIndex);
      if (_currentSong != null) _history.add(_currentSong!);
      _currentSong = item.song;
      return _currentSong;
    } else {
      // Selected from automatic pool
      final autoIndex = combinedIndex - _manualQueue.length;
      final item = _automaticPool.removeAt(autoIndex);
      if (_currentSong != null) _history.add(_currentSong!);
      _currentSong = item.song;
      return _currentSong;
    }
  }

  /// Toggle shuffle ON/OFF
  void toggleShuffle([bool? enable]) {
    _shuffleEngine.toggleShuffle(enable);
    _syncAutomaticPoolFromShuffleEngine();
  }

  /// Set repeat mode
  void setRepeatMode(RepeatMode mode) {
    _shuffleEngine.setRepeatMode(mode);
  }

  /// Full state export for persistence
  Map<String, dynamic> exportState() {
    return {
      'currentSong': _currentSong?.toMap(),
      'manualQueue': _manualQueue.map((item) => item.toMap()).toList(),
      'automaticPool': _automaticPool.map((item) => item.toMap()).toList(),
      'history': _history.map((s) => s.toMap()).toList(),
      'shuffleEngine': _shuffleEngine.exportState(),
    };
  }

  /// Full state restoration from persistence
  void restoreState(Map<String, dynamic> state, List<Song> allAvailableSongs) {
    final songMap = {for (final s in allAvailableSongs) s.id: s};

    if (state['currentSong'] != null) {
      final songMapData = state['currentSong'] as Map<String, dynamic>;
      final songId = songMapData['id'] as String;
      _currentSong = songMap[songId] ?? Song.fromMap(songMapData);
    }

    _manualQueue.clear();
    final manualData = List<Map<String, dynamic>>.from(state['manualQueue'] ?? []);
    for (final m in manualData) {
      _manualQueue.add(QueueItem.fromMap(m));
    }

    _automaticPool.clear();
    final autoData = List<Map<String, dynamic>>.from(state['automaticPool'] ?? []);
    for (final a in autoData) {
      _automaticPool.add(QueueItem.fromMap(a));
    }

    _history.clear();
    final histData = List<Map<String, dynamic>>.from(state['history'] ?? []);
    for (final h in histData) {
      _history.add(Song.fromMap(h));
    }

    if (state['shuffleEngine'] != null) {
      _shuffleEngine.restoreState(
        state: state['shuffleEngine'] as Map<String, dynamic>,
        allAvailableSongs: allAvailableSongs,
      );
    }
  }
}
