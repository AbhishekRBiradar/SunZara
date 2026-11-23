import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/audio/domain/sunzara_audio_handler.dart';
import 'features/audio/presentation/playback_controller.dart';
import 'features/database/app_database.dart';
import 'features/library/data/mediastore_scanner.dart';
import 'features/library/domain/music_repository.dart';
import 'features/navigation/main_navigation_shell.dart';
import 'features/queue/domain/queue_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore saved theme preference (preset & mode)
  await ThemeController.instance.restoreSavedTheme();

  // Request notification permissions for playback controls and lock screen on Android 13+
  if (Platform.isAndroid) {
    try {
      await Permission.notification.request();
    } catch (_) {}
  }

  // Initialize background AudioHandler with persistent media notification
  final audioHandler = await AudioService.init(
    builder: () => SunZaraAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.sunzara.app.channel.audio.v2',
      androidNotificationChannelName: 'SunZara Music Playback',
      androidNotificationChannelDescription: 'Media playback and lock screen controls',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: true,
      androidResumeOnClick: false,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidShowNotificationBadge: true,
      notificationColor: const Color(0xFF00AEBB),
    ),
  );

  // Initialize SQLite database and repository
  final database = AppDatabase();
  final repository = MusicRepository(database);

  // Initialize queue manager and centralized playback controller
  final queueManager = QueueManager();
  final playbackController = PlaybackController(
    audioHandler: audioHandler,
    queueManager: queueManager,
    repository: repository,
  );

  final scanner = MediaStoreScanner(repository);

  // Restore previous playback state (paused by default on launch)
  await playbackController.restorePersistedState();

  runApp(
    ProviderScope(
      overrides: [
        playbackControllerProvider.overrideWithValue(playbackController),
      ],
      child: SunZaraApp(
        repository: repository,
        playbackController: playbackController,
        scanner: scanner,
      ),
    ),
  );
}

class SunZaraApp extends StatelessWidget {
  final MusicRepository repository;
  final PlaybackController playbackController;
  final MediaStoreScanner scanner;

  const SunZaraApp({
    super.key,
    required this.repository,
    required this.playbackController,
    required this.scanner,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final activePalette = ThemeController.instance.activePalette;
        final currentTheme = AppTheme.createThemeData(activePalette);
        return MaterialApp(
          title: 'SunZara (सुन ज़रा)',
          debugShowCheckedModeBanner: false,
          theme: currentTheme,
          darkTheme: currentTheme,
          themeMode: ThemeController.instance.themeMode,
          home: MainNavigationShell(
            key: const PageStorageKey('main_nav_shell'),
            repository: repository,
            playbackController: playbackController,
            scanner: scanner,
          ),
        );
      },
    );
  }
}
