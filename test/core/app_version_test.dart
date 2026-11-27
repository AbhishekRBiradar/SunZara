import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunzara/core/services/app_version_service.dart';
import 'package:sunzara/features/audio/domain/local_stream_proxy.dart';
import 'package:sunzara/features/audio/domain/sunzara_audio_handler.dart';
import 'package:sunzara/features/audio/domain/youtube_stream_service.dart';
import 'package:sunzara/features/audio/presentation/playback_controller.dart';
import 'package:sunzara/features/database/app_database.dart';
import 'package:sunzara/features/library/data/mediastore_scanner.dart';
import 'package:sunzara/features/library/domain/music_repository.dart';
import 'package:sunzara/features/queue/domain/queue_manager.dart';
import 'package:sunzara/features/settings/presentation/settings_screen.dart';

class _TestAudioHandler extends SunZaraAudioHandler {
  @override
  Future<void> release() async {}
}

void main() {
  tearDown(() {
    AppVersionService.instance.resetCache();
  });

  group('App Versioning', () {
    test('AppVersionInfo.fallback matches pubspec.yaml version', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);

      final match = RegExp(
        r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
        multiLine: true,
      ).firstMatch(pubspecFile.readAsStringSync());

      expect(match, isNotNull, reason: 'pubspec.yaml must declare version: X.Y.Z+N');
      expect(AppVersionInfo.fallback.versionName, match!.group(1));
      expect(AppVersionInfo.fallback.buildNumber, int.parse(match.group(2)!));
    });

    testWidgets('SettingsScreen displays resolved live version info', (tester) async {
      AppVersionService.instance.testLoader = () async => const AppVersionInfo(
            versionName: '1.2.3',
            buildNumber: 7,
          );

      final db = AppDatabase(NativeDatabase.memory());
      final repo = MusicRepository(db);
      final qm = QueueManager();
      final handler = _TestAudioHandler();
      final controller = PlaybackController(
        audioHandler: handler,
        queueManager: qm,
        repository: repo,
      );
      final scanner = MediaStoreScanner(repo);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            repository: repo,
            playbackController: controller,
            scanner: scanner,
          ),
        ),
      );

      await tester.pump();
      await tester.scrollUntilVisible(
        find.textContaining('Version 1.2.3 (Build 7)'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.textContaining('Version 1.2.3 (Build 7)'), findsOneWidget);

      controller.dispose();
      scanner.dispose();
      LocalStreamProxy.instance.close();
      YouTubeStreamService.instance.close();
      await db.close();
    });
  });
}
