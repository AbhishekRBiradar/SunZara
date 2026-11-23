import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:sunzara/features/audio/domain/sunzara_audio_handler.dart';
import 'package:sunzara/features/audio/presentation/playback_controller.dart';
import 'package:sunzara/features/database/app_database.dart';
import 'package:sunzara/features/library/data/mediastore_scanner.dart';
import 'package:sunzara/features/library/domain/music_repository.dart';
import 'package:sunzara/features/queue/domain/queue_manager.dart';
import 'package:sunzara/main.dart';

class TestAudioHandler extends SunZaraAudioHandler {
  @override
  Future<void> release() async {}
}

void main() {
  testWidgets('SunZaraApp initializes and renders navigation shell', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = MusicRepository(db);
    final qm = QueueManager();
    final handler = TestAudioHandler();
    final controller = PlaybackController(
      audioHandler: handler,
      queueManager: qm,
      repository: repo,
    );
    final scanner = MediaStoreScanner(repo);

    await tester.pumpWidget(
      SunZaraApp(
        repository: repo,
        playbackController: controller,
        scanner: scanner,
      ),
    );

    expect(find.text('सुन ज़रा'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    controller.dispose();
    scanner.dispose();
    await db.close();
  });
}
