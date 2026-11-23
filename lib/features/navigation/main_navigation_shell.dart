import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_controller.dart';
import '../audio/domain/playback_state_model.dart';
import '../audio/presentation/playback_controller.dart';
import '../favorites/presentation/favorites_screen.dart';
import '../home/presentation/home_screen.dart';
import '../library/data/mediastore_scanner.dart';
import '../library/domain/music_repository.dart';
import '../library/presentation/library_screen.dart';
import '../now_playing/presentation/widgets/mini_player.dart';
import '../playlists/presentation/playlists_screen.dart';
import '../settings/presentation/settings_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final MusicRepository repository;
  final PlaybackController playbackController;
  final MediaStoreScanner scanner;

  const MainNavigationShell({
    super.key,
    required this.repository,
    required this.playbackController,
    required this.scanner,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  List<Widget> _buildTabs() => [
        HomeScreen(
          key: const ValueKey('tab_home'),
          repository: widget.repository,
          playbackController: widget.playbackController,
          scanner: widget.scanner,
          onOpenLibrary: () => setState(() => _currentIndex = 1),
          onOpenSettings: () => setState(() => _currentIndex = 4),
        ),
        LibraryScreen(
          key: const ValueKey('tab_library'),
          repository: widget.repository,
          playbackController: widget.playbackController,
        ),
        PlaylistsScreen(
          key: const ValueKey('tab_playlists'),
          repository: widget.repository,
          playbackController: widget.playbackController,
        ),
        FavoritesScreen(
          key: const ValueKey('tab_favorites'),
          repository: widget.repository,
          playbackController: widget.playbackController,
        ),
        SettingsScreen(
          key: const ValueKey('tab_settings'),
          repository: widget.repository,
          playbackController: widget.playbackController,
          scanner: widget.scanner,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        return ValueListenableBuilder<PlaybackStateModel>(
          valueListenable: widget.playbackController,
          builder: (context, playbackState, child) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: IndexedStack(
                index: _currentIndex,
                children: _buildTabs(),
              ),
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mini Player pinned directly above the navigation bar without covering content
                  if (playbackState.currentSong != null)
                    MiniPlayer(
                      playbackState: playbackState,
                      controller: widget.playbackController,
                    ),
                  NavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
                    backgroundColor: AppColors.surface,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home_rounded),
                        label: 'Home',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.library_music_outlined),
                        selectedIcon: Icon(Icons.library_music_rounded),
                        label: 'Library',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.playlist_play_rounded),
                        selectedIcon: Icon(Icons.playlist_play_rounded),
                        label: 'Playlists',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.favorite_outline_rounded),
                        selectedIcon: Icon(Icons.favorite_rounded),
                        label: 'Favorites',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings_rounded),
                        label: 'Settings',
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
