import 'package:flutter/material.dart';
import '../../../core/models/playback_context.dart';
import '../../../core/models/song.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/song_artwork.dart';
import '../../../core/widgets/sunzara_logo.dart';
import '../../audio/presentation/playback_controller.dart';
import '../../library/data/mediastore_scanner.dart';
import '../../library/domain/music_repository.dart';
import '../../search/presentation/online_search_screen.dart';

class HomeScreen extends StatefulWidget {
  final MusicRepository repository;
  final PlaybackController playbackController;
  final MediaStoreScanner scanner;
  final VoidCallback onOpenLibrary;
  final VoidCallback onOpenSettings;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.playbackController,
    required this.scanner,
    required this.onOpenLibrary,
    required this.onOpenSettings,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> _recentlyAdded = [];
  List<Song> _recentlyPlayed = [];
  List<Song> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() => _isLoading = true);
    final added = await widget.repository.getRecentlyAdded(limit: 10);
    final played = await widget.repository.getRecentlyPlayed(limit: 10);
    final favs = await widget.repository.getFavoriteSongs();

    if (mounted) {
      setState(() {
        _recentlyAdded = added;
        _recentlyPlayed = played;
        _favorites = favs;
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning.';
    if (hour >= 12 && hour < 17) return 'Hey, good afternoon.';
    if (hour >= 17 && hour < 21) return 'Good evening.';
    return 'What are we listening to tonight?';
  }

  void _triggerScan() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StreamBuilder<ScanProgress>(
          stream: widget.scanner.progressStream,
          builder: (context, snapshot) {
            final progress = snapshot.data;
            final isDone = progress?.stage == ScanStage.completed ||
                progress?.stage == ScanStage.permissionDenied ||
                progress?.stage == ScanStage.error;

            if (isDone && mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadHomeData();
              });
            }

            return AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.sync_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Scanning Music', style: AppTypography.headingSmall),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress?.message ?? 'Discovering audio tracks...',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress?.progressFraction,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  if (progress != null && progress.total > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${progress.count} / ${progress.total} tracks',
                        style: AppTypography.caption,
                      ),
                    ),
                ],
              ),
              actions: [
                if (!isDone)
                  TextButton(
                    onPressed: () {
                      widget.scanner.cancelScan();
                      Navigator.pop(context);
                    },
                    child: Text('Cancel', style: TextStyle(color: AppColors.error)),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Done', style: TextStyle(color: AppColors.primary)),
                  ),
              ],
            );
          },
        );
      },
    );

    widget.scanner.scanMusic();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDarkMode;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            toolbarHeight: 70,
            title: Row(
              children: [
                const SunZaraLogo(size: 34),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('सुन ज़रा', style: AppTypography.hindiIdentity),
                    Text('Your music. Your world.', style: AppTypography.caption),
                  ],
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => ThemeController.instance.toggleDarkMode(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          size: 19,
                          color: AppColors.primary,
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: isDark,
                            activeColor: AppColors.primary,
                            activeTrackColor: AppColors.surfaceHighlight,
                            inactiveThumbColor: AppColors.primary,
                            inactiveTrackColor: AppColors.surfaceElevated,
                            onChanged: (val) {
                              ThemeController.instance.setDarkMode(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.travel_explore_rounded, color: AppColors.primary),
                tooltip: 'Search Online Music',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OnlineSearchScreen(
                        repository: widget.repository,
                        playbackController: widget.playbackController,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.sync_rounded, color: AppColors.primary),
                tooltip: 'Scan My Music',
                onPressed: _triggerScan,
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
                onPressed: widget.onOpenSettings,
              ),
            ],
          ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceElevated,
              onRefresh: _loadHomeData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personalized greeting
                    Text(_getGreeting(), style: AppTypography.headingLarge),
                    const SizedBox(height: 14),
                    // Quick Online Music Search Bar
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OnlineSearchScreen(
                              repository: widget.repository,
                              playbackController: widget.playbackController,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider, width: 0.9),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Search any song on the internet...',
                                style: AppTypography.caption.copyWith(fontSize: 13),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Voice Search',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              icon: Icon(Icons.mic_rounded, color: AppColors.primary, size: 20),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OnlineSearchScreen(
                                      repository: widget.repository,
                                      playbackController: widget.playbackController,
                                      startVoiceSearch: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 22),
                            label: Text(
                              'Play All',
                              style: AppTypography.button.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              final all = await widget.repository.getAllSongs();
                              if (all.isNotEmpty) {
                                widget.playbackController.playSong(
                                  all.first,
                                  PlaybackContext.library,
                                  all,
                                  shuffleEnabled: false,
                                );
                              } else {
                                _triggerScan();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary.withAlpha(200), width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.shuffle_rounded, size: 22),
                            label: Text(
                              'Shuffle All',
                              style: AppTypography.button.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              final all = await widget.repository.getAllSongs();
                              if (all.isNotEmpty) {
                                widget.playbackController.playSong(
                                  all.first,
                                  PlaybackContext.library,
                                  all,
                                  shuffleEnabled: true,
                                );
                              } else {
                                _triggerScan();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Empty State Check
                    if (_recentlyAdded.isEmpty && _recentlyPlayed.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider, width: 0.8),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.music_note_rounded, size: 56, color: AppColors.primary),
                            const SizedBox(height: 12),
                            Text('Your music journey starts here.', style: AppTypography.headingMedium),
                            const SizedBox(height: 6),
                            Text(
                              "Let's find the music stored on your device.",
                              style: AppTypography.caption,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.sync_rounded),
                              label: const Text('Scan My Music'),
                              onPressed: _triggerScan,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Continue Listening (Recently Played)
                      if (_recentlyPlayed.isNotEmpty) ...[
                        _buildSectionHeader('Continue Listening', onSeeAll: widget.onOpenLibrary),
                        const SizedBox(height: 12),
                        _buildHorizontalSongList(_recentlyPlayed),
                        const SizedBox(height: 24),
                      ],

                      // Recently Added
                      if (_recentlyAdded.isNotEmpty) ...[
                        _buildSectionHeader('Recently Added', onSeeAll: widget.onOpenLibrary),
                        const SizedBox(height: 12),
                        _buildHorizontalSongList(_recentlyAdded),
                        const SizedBox(height: 24),
                      ],

                      // Favorites
                      if (_favorites.isNotEmpty) ...[
                        _buildSectionHeader('Favorites', onSeeAll: widget.onOpenLibrary),
                        const SizedBox(height: 12),
                        _buildHorizontalSongList(_favorites),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ],
                ),
              ),
            ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.headingMedium.copyWith(fontSize: 18)),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'See All',
              style: AppTypography.button.copyWith(color: AppColors.primary, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalSongList(List<Song> songs) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        separatorBuilder: (_, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final song = songs[index];
          return GestureDetector(
            onTap: () {
              widget.playbackController.playSong(
                song,
                PlaybackContext.library,
                [song],
              );
            },
            child: SizedBox(
              width: 126,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SongArtwork(
                    song: song,
                    size: 126,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.title,
                    style: AppTypography.songTitle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: AppTypography.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
