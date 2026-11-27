import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunzara/core/models/playback_context.dart';
import 'package:sunzara/core/models/song.dart';
import 'package:sunzara/features/audio/domain/playback_state_model.dart';
import 'package:sunzara/features/audio/domain/sunzara_audio_handler.dart';
import 'package:sunzara/features/audio/presentation/playback_controller.dart';
import 'package:sunzara/features/database/app_database.dart';
import 'package:sunzara/features/library/domain/music_repository.dart';
import 'package:sunzara/features/now_playing/presentation/widgets/mini_player.dart';
import 'package:sunzara/features/queue/domain/queue_manager.dart';
import 'package:sunzara/features/search/presentation/online_search_screen.dart';

class _WidgetFakeAudioHandler extends SunZaraAudioHandler {
  @override
  Future<void> setSong(Song song, {bool autoPlay = true, Duration? startPosition}) async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> release() async {}
}

Song _makeSong(String id, String title) {
  return Song(
    id: id,
    title: title,
    artist: 'Artist $id',
    album: 'Online Search',
    durationMs: 185000,
    fileSize: 0,
    filePath: '/tmp/$id.mp3',
    folder: 'Test',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late MusicRepository repo;
  late QueueManager qm;
  late _WidgetFakeAudioHandler handler;
  late PlaybackController controller;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MusicRepository(db);
    qm = QueueManager();
    handler = _WidgetFakeAudioHandler();
    controller = PlaybackController(
      audioHandler: handler,
      queueManager: qm,
      repository: repo,
    );
  });

  tearDown(() async {
    controller.dispose();
    await handler.release();
    await db.close();
  });

  testWidgets('MiniPlayer heart button toggles favorite and creates Liked Songs playlist', (tester) async {
    final s1 = _makeSong('yt_1', 'First Song');
    await repo.insertOrUpdateSong(s1);
    await controller.playSong(s1, PlaybackContext.library, [s1]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<PlaybackStateModel>(
            valueListenable: controller,
            builder: (context, pbState, _) => MiniPlayer(
              playbackState: pbState,
              controller: controller,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(controller.state.currentSong?.isFavorite, isTrue);

    final playlists = await repo.getAllPlaylists();
    final liked = playlists.firstWhere((p) => p.name == AppDatabase.likedSongsPlaylistName);
    final songsInLiked = await repo.getPlaylistSongs(liked.id);
    expect(songsInLiked.map((s) => s.id), ['yt_1']);
  });

  testWidgets('OnlineSearchScreen tap leaves automatic queue empty and left/right swipe queues song', (tester) async {
    final s1 = _makeSong('yt_a', 'Alpha Track');
    final s2 = _makeSong('yt_b', 'Beta Track');
    final s3 = _makeSong('yt_c', 'Gamma Track');

    await tester.pumpWidget(
      MaterialApp(
        home: OnlineSearchScreen(
          repository: repo,
          playbackController: controller,
          initialResults: [s1, s2, s3],
        ),
      ),
    );

    // Tapping Alpha Track must not populate automaticPool with Beta/Gamma
    await tester.tap(find.text('Alpha Track'));
    await tester.pumpAndSettle();
    expect(controller.state.currentSong?.id, 'yt_a');
    expect(controller.state.automaticPool, isEmpty);
    expect(controller.state.manualQueue, isEmpty);

    // Swipe Beta Track RIGHT to queue it; row remains in list
    await tester.drag(find.text('Beta Track'), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(controller.state.manualQueue.map((q) => q.song.id), ['yt_b']);
    expect(find.text('Beta Track'), findsOneWidget);

    // Swipe Gamma Track LEFT to queue it; row remains in list
    await tester.drag(find.text('Gamma Track'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(controller.state.manualQueue.map((q) => q.song.id), ['yt_b', 'yt_c']);
    expect(find.text('Gamma Track'), findsOneWidget);
  });
}
