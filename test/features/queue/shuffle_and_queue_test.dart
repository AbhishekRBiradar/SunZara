import 'package:flutter_test/flutter_test.dart';
import 'package:sunzara/core/models/playback_context.dart';
import 'package:sunzara/core/models/song.dart';
import 'package:sunzara/features/queue/domain/queue_manager.dart';
import 'package:sunzara/features/queue/domain/shuffle_engine.dart';

Song createDummySong(String id, String title) {
  return Song(
    id: id,
    title: title,
    artist: 'Artist $id',
    album: 'Album $id',
    durationMs: 180000,
    fileSize: 4000000,
    filePath: '/music/$id.mp3',
    folder: 'Music',
  );
}

void main() {
  group('Intelligent Shuffle Engine Tests', () {
    test('Empty library handles next and previous safely', () {
      final engine = ShuffleEngine();
      engine.initializeContext(PlaybackContext.library, []);

      expect(engine.currentSong, isNull);
      expect(engine.nextTrack(), isNull);
      expect(engine.previousTrack(), isNull);
    });

    test('One-track library starts track and handles boundaries', () {
      final engine = ShuffleEngine();
      final songA = createDummySong('1', 'Song A');
      engine.initializeContext(PlaybackContext.library, [songA]);

      expect(engine.currentSong?.id, '1');
      // In Repeat OFF, next returns null after single song is played
      expect(engine.nextTrack(), isNull);

      // Repeat ONE stays on same song
      engine.setRepeatMode(RepeatMode.one);
      expect(engine.nextTrack()?.id, '1');
    });

    test('Two-track library plays starting track first and randomizes remaining without repetition', () {
      final engine = ShuffleEngine();
      final songA = createDummySong('1', 'Song A');
      final songB = createDummySong('2', 'Song B');

      engine.initializeContext(
        PlaybackContext.library,
        [songA, songB],
        startSong: songA,
        shuffleEnabled: true,
      );

      expect(engine.currentSong?.id, '1');
      final second = engine.nextTrack();
      expect(second?.id, '2');
      // End of cycle in Repeat OFF
      expect(engine.nextTrack(), isNull);
    });

    test('Shuffle cycle plays every track once and regenerates on Repeat ALL', () {
      final engine = ShuffleEngine(repeatMode: RepeatMode.all);
      final songs = List.generate(5, (i) => createDummySong('$i', 'Song $i'));

      engine.initializeContext(
        PlaybackContext.library,
        songs,
        startSong: songs[0],
        shuffleEnabled: true,
      );

      final playedInCycle1 = <String>[engine.currentSong!.id];
      for (var i = 0; i < 4; i++) {
        final next = engine.nextTrack();
        expect(next, isNotNull);
        playedInCycle1.add(next!.id);
      }

      // All 5 songs played exactly once
      expect(playedInCycle1.toSet().length, 5);

      // Next track starts Cycle 2
      final cycle2First = engine.nextTrack();
      expect(cycle2First, isNotNull);
      // Avoid choosing previous cycle's final track as first track when alternatives exist
      expect(cycle2First?.id != playedInCycle1.last, isTrue);
    });

    test('Sequential playback when Shuffle is OFF', () {
      final engine = ShuffleEngine(isShuffleEnabled: false);
      final songs = List.generate(4, (i) => createDummySong('$i', 'Song $i'));

      engine.initializeContext(
        PlaybackContext.library,
        songs,
        startSong: songs[0],
        shuffleEnabled: false,
      );

      expect(engine.currentSong?.id, '0');
      expect(engine.nextTrack()?.id, '1');
      expect(engine.nextTrack()?.id, '2');
      expect(engine.nextTrack()?.id, '3');
      expect(engine.nextTrack(), isNull);
    });
  });

  group('Advanced Queue Manager Tests', () {
    test('Play Now sets current song and initializes context pool', () {
      final qm = QueueManager();
      final songs = List.generate(5, (i) => createDummySong('$i', 'Song $i'));

      qm.playNow(
        song: songs[0],
        context: PlaybackContext.library,
        contextTracks: songs,
      );

      expect(qm.currentSong?.id, '0');
      expect(qm.automaticPool.length, 4);
      expect(qm.manualQueue.isEmpty, isTrue);
    });

    test('Manual queue has absolute priority over automatic pool', () {
      final qm = QueueManager();
      final songs = List.generate(4, (i) => createDummySong('$i', 'Song $i'));
      final manualSongX = createDummySong('X', 'Manual X');

      qm.playNow(
        song: songs[0],
        context: PlaybackContext.library,
        contextTracks: songs,
      );

      qm.addToQueue(manualSongX);

      // Manual song must be played before any automatic pool songs
      final next = qm.moveToNext();
      expect(next?.id, 'X');
      expect(qm.manualQueue.isEmpty, isTrue);

      // Subsequent song comes from automatic pool
      final autoNext = qm.moveToNext();
      expect(autoNext, isNotNull);
      expect(songs.sublist(1).map((s) => s.id).contains(autoNext?.id), isTrue);
    });

    test('Play Next inserts track immediately at index 0 of manual queue', () {
      final qm = QueueManager();
      final songs = List.generate(4, (i) => createDummySong('$i', 'Song $i'));
      final songD = createDummySong('D', 'Song D');
      final songE = createDummySong('E', 'Song E');

      qm.playNow(
        song: songs[0],
        context: PlaybackContext.library,
        contextTracks: songs,
      );

      qm.addToQueue(songE); // Manual queue: [E]
      qm.playNext(songD); // Manual queue: [D, E]

      // Next song must be D, then E, then automatic pool
      expect(qm.moveToNext()?.id, 'D');
      expect(qm.moveToNext()?.id, 'E');
      expect(qm.manualQueue.isEmpty, isTrue);
    });

    test('Drag reordering in manual queue and automatic pool', () {
      final qm = QueueManager();
      final song1 = createDummySong('1', '1');
      final song2 = createDummySong('2', '2');
      final song3 = createDummySong('3', '3');

      qm.addToQueue(song1);
      qm.addToQueue(song2);
      qm.addToQueue(song3);

      // Current manual queue: [1, 2, 3]
      // Reorder 0 to 2 -> [2, 1, 3]
      qm.reorderManualQueue(0, 2);
      expect(qm.manualQueue[0].song.id, '2');
      expect(qm.manualQueue[1].song.id, '1');
      expect(qm.manualQueue[2].song.id, '3');
    });

    test('Duplicate songs are allowed as distinct queue entries when intentionally added', () {
      final qm = QueueManager();
      final songA = createDummySong('A', 'Song A');

      qm.addToQueue(songA);
      qm.addToQueue(songA);

      expect(qm.manualQueue.length, 2);
      expect(qm.manualQueue[0].queueId != qm.manualQueue[1].queueId, isTrue);

      // Remove one duplicate by queueId
      final removed = qm.removeFromQueue(qm.manualQueue[0].queueId);
      expect(removed, isTrue);
      expect(qm.manualQueue.length, 1);
    });

    test('Persistence export and restore maintains queue integrity', () {
      final qm = QueueManager();
      final songs = List.generate(4, (i) => createDummySong('$i', 'Song $i'));
      final extra = createDummySong('manual_1', 'Manual');

      qm.playNow(
        song: songs[0],
        context: PlaybackContext.library,
        contextTracks: songs,
      );
      qm.addToQueue(extra);

      final exportedState = qm.exportState();

      final newQm = QueueManager();
      newQm.restoreState(exportedState, [...songs, extra]);

      expect(newQm.currentSong?.id, '0');
      expect(newQm.manualQueue.length, 1);
      expect(newQm.manualQueue[0].song.id, 'manual_1');
      expect(newQm.automaticPool.length, qm.automaticPool.length);
    });
  });
}
