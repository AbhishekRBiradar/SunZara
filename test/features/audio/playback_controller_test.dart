import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:sunzara/core/models/playback_context.dart';
import 'package:sunzara/core/models/song.dart';
import 'package:sunzara/features/audio/domain/sunzara_audio_handler.dart';
import 'package:sunzara/features/audio/presentation/playback_controller.dart';
import 'package:sunzara/features/database/app_database.dart';
import 'package:sunzara/features/library/domain/music_repository.dart';
import 'package:sunzara/features/queue/domain/queue_manager.dart';

class FakeAudioHandler extends SunZaraAudioHandler {
  Song? activeSong;
  bool isPlayingMedia = false;

  @override
  Future<void> setSong(Song song, {bool autoPlay = true, Duration? startPosition}) async {
    activeSong = song;
    isPlayingMedia = autoPlay;
  }

  @override
  Future<void> play() async {
    isPlayingMedia = true;
  }

  @override
  Future<void> pause() async {
    isPlayingMedia = false;
  }

  @override
  Future<void> stop() async {
    isPlayingMedia = false;
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> release() async {}
}

Song createSong(String id) {
  return Song(
    id: id,
    title: 'Song $id',
    artist: 'Artist $id',
    album: 'Album $id',
    durationMs: 200000,
    fileSize: 4000000,
    filePath: '/music/song_$id.mp3',
    folder: 'Music',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late MusicRepository repo;
  late QueueManager qm;
  late FakeAudioHandler fakeHandler;
  late PlaybackController controller;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MusicRepository(db);
    qm = QueueManager();
    fakeHandler = FakeAudioHandler();
    controller = PlaybackController(
      audioHandler: fakeHandler,
      queueManager: qm,
      repository: repo,
    );
  });

  tearDown(() async {
    controller.dispose();
    await fakeHandler.release();
    await db.close();
  });

  group('PlaybackController Central Coordinator Tests', () {
    test('playSong sets current song and initializes queue and context', () async {
      final s1 = createSong('1');
      final s2 = createSong('2');
      final s3 = createSong('3');

      await controller.playSong(s1, PlaybackContext.library, [s1, s2, s3]);

      expect(controller.state.currentSong?.id, '1');
      expect(controller.state.context.type, PlaybackContextType.library);
      expect(controller.state.automaticPool.length, 2);
      expect(fakeHandler.activeSong?.id, '1');
    });

    test('Cycle repeat mode progresses: off -> all -> one -> off', () {
      expect(controller.state.repeatMode, RepeatMode.off);

      controller.cycleRepeatMode();
      expect(controller.state.repeatMode, RepeatMode.all);

      controller.cycleRepeatMode();
      expect(controller.state.repeatMode, RepeatMode.one);

      controller.cycleRepeatMode();
      expect(controller.state.repeatMode, RepeatMode.off);
    });

    test('Play Next inserts at the front of the manual queue', () async {
      final s1 = createSong('1');
      final s2 = createSong('2');
      final sNext = createSong('NEXT');

      await controller.playSong(s1, PlaybackContext.library, [s1, s2]);
      controller.playNext(sNext);

      expect(controller.state.manualQueue.isNotEmpty, isTrue);
      expect(controller.state.manualQueue.first.song.id, 'NEXT');
    });

    test('toggleShuffle updates state and regenerates upcoming queue', () async {
      final s1 = createSong('1');
      final s2 = createSong('2');
      final s3 = createSong('3');

      await controller.playSong(s1, PlaybackContext.library, [s1, s2, s3]);
      final initialShuffle = controller.state.isShuffleEnabled;

      controller.toggleShuffle();
      expect(controller.state.isShuffleEnabled, !initialShuffle);
    });

    test('Single-track selection leaves automatic queue empty and preserves like across addToQueue', () async {
      final s1 = createSong('1');
      final s2 = createSong('2');

      await controller.playSong(
        s1,
        const PlaybackContext(
          type: PlaybackContextType.search,
          id: 'online_search',
          name: 'Online Search',
        ),
        [s1],
      );

      expect(controller.state.currentSong?.id, '1');
      expect(controller.state.automaticPool, isEmpty);
      expect(controller.state.manualQueue, isEmpty);

      await controller.toggleFavorite();
      expect(controller.state.currentSong?.isFavorite, isTrue);

      // Adding another song via queue must preserve currentSong's liked status
      controller.addToQueue(s2);
      expect(controller.state.manualQueue.length, 1);
      expect(controller.state.manualQueue.first.song.id, '2');
      expect(controller.state.currentSong?.isFavorite, isTrue);

      final playlists = await repo.getAllPlaylists();
      final liked = playlists.firstWhere((p) => p.name == AppDatabase.likedSongsPlaylistName);
      final likedSongs = await repo.getPlaylistSongs(liked.id);
      expect(likedSongs.map((s) => s.id), contains('1'));
    });
  });
}
