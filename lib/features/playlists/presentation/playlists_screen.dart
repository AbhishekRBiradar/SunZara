import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/playback_context.dart';
import '../../../core/models/playlist.dart';
import '../../../core/models/song.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/deterministic_artwork.dart';
import '../../../core/widgets/song_artwork.dart';
import '../../audio/domain/playback_state_model.dart';
import '../../audio/presentation/playback_controller.dart';
import '../../database/app_database.dart';
import '../../library/domain/music_repository.dart';
import '../../now_playing/presentation/widgets/mini_player.dart';
import '../../audio/domain/youtube_stream_service.dart';

class PlaylistsScreen extends StatefulWidget {
  final MusicRepository repository;
  final PlaybackController playbackController;

  const PlaylistsScreen({
    super.key,
    required this.repository,
    required this.playbackController,
  });

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  List<Playlist> _playlists = [];
  bool _isLoading = true;
  StreamSubscription<void>? _repoSub;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
    _repoSub = widget.repository.changes.listen((_) {
      _loadPlaylists(showLoading: false);
    });
  }

  @override
  void dispose() {
    _repoSub?.cancel();
    super.dispose();
  }

  Future<void> _loadPlaylists({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    final pls = await widget.repository.getAllPlaylists();
    pls.sort((a, b) {
      final aLiked = a.id == AppDatabase.likedSongsPlaylistId ||
          a.name.trim().toLowerCase() == AppDatabase.likedSongsPlaylistName.toLowerCase();
      final bLiked = b.id == AppDatabase.likedSongsPlaylistId ||
          b.name.trim().toLowerCase() == AppDatabase.likedSongsPlaylistName.toLowerCase();
      if (aLiked != bLiked) return aLiked ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    if (mounted) {
      setState(() {
        _playlists = pls;
        _isLoading = false;
      });
    }
  }

  void _showCreatePlaylistDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: Text('New Playlist', style: AppTypography.headingSmall),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: 'Playlist Name',
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
              ),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await widget.repository.createPlaylist(name);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  _loadPlaylists();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Playlists', style: AppTypography.headingMedium),
            actions: [
              IconButton(
                icon: Icon(Icons.add_rounded, color: AppColors.primary),
                tooltip: 'Create Playlist',
                onPressed: _showCreatePlaylistDialog,
              ),
            ],
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceElevated,
                  onRefresh: _loadPlaylists,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // Smart Collections Header
                      Text('Smart Collections', style: AppTypography.headingSmall),
                      const SizedBox(height: 12),
                      _buildSmartCollectionsGrid(),
                      const SizedBox(height: 24),

                      // User Playlists Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Your Playlists (${_playlists.length})', style: AppTypography.headingSmall),
                          TextButton.icon(
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('New'),
                            onPressed: _showCreatePlaylistDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_playlists.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          child: Text(
                            'No custom playlists created yet.',
                            style: AppTypography.caption,
                          ),
                        )
                      else
                        ..._playlists.map((pl) => _buildPlaylistTile(pl)),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSmartCollectionsGrid() {
    final collections = [
      {
        'title': 'Recently Added',
        'icon': Icons.fiber_new_rounded,
        'action': () async => _openSmartCollection('Recently Added', await widget.repository.getRecentlyAdded()),
      },
      {
        'title': 'Recently Played',
        'icon': Icons.history_rounded,
        'action': () async => _openSmartCollection('Recently Played', await widget.repository.getRecentlyPlayed()),
      },
      {
        'title': 'Most Played',
        'icon': Icons.local_fire_department_rounded,
        'action': () async => _openSmartCollection('Most Played', await widget.repository.getMostPlayed()),
      },
      {
        'title': 'Never Played',
        'icon': Icons.hourglass_empty_rounded,
        'action': () async => _openSmartCollection('Never Played', await widget.repository.getNeverPlayed()),
      },
      {
        'title': 'Longest Tracks',
        'icon': Icons.timelapse_rounded,
        'action': () async => _openSmartCollection('Longest Tracks', await widget.repository.getLongestTracks()),
      },
    ];

    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: collections.length,
        separatorBuilder: (_, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final col = collections[index];
          return GestureDetector(
            onTap: col['action'] as VoidCallback,
            child: Container(
              width: 130,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(col['icon'] as IconData, color: AppColors.primary, size: 28),
                  Text(
                    col['title'] as String,
                    style: AppTypography.songTitle.copyWith(fontSize: 13),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaylistTile(Playlist pl) {
    final isLikedPlaylist = pl.id == AppDatabase.likedSongsPlaylistId ||
        pl.name.trim().toLowerCase() == AppDatabase.likedSongsPlaylistName.toLowerCase();
    return ListTile(
      leading: isLikedPlaylist
          ? Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withAlpha(110), width: 1),
              ),
              child: Icon(Icons.favorite_rounded, color: AppColors.primary, size: 24),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: DeterministicArtwork(seed: pl.id, size: 48),
            ),
      title: Text(pl.name, style: AppTypography.songTitle),
      subtitle: Text('${pl.trackCount} tracks', style: AppTypography.caption),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded, size: 20),
        onSelected: (val) async {
          if (val == 'delete') {
            await widget.repository.deletePlaylist(pl.id);
            _loadPlaylists();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text('Delete Playlist', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
      onTap: () => _openPlaylistDetail(pl),
    );
  }

  void _openSmartCollection(String title, List<Song> songs) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PlaylistDetailPage(
          title: title,
          songs: songs,
          isSmart: true,
          playbackController: widget.playbackController,
        ),
      ),
    );
  }

  void _openPlaylistDetail(Playlist pl) async {
    final songs = await widget.repository.getPlaylistSongs(pl.id);
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PlaylistDetailPage(
          title: pl.name,
          playlistId: pl.id,
          songs: songs,
          isSmart: false,
          playbackController: widget.playbackController,
          repository: widget.repository,
        ),
      ),
    ).then((_) => _loadPlaylists());
  }
}

class _PlaylistDetailPage extends StatefulWidget {
  final String title;
  final String? playlistId;
  final List<Song> songs;
  final bool isSmart;
  final PlaybackController playbackController;
  final MusicRepository? repository;

  const _PlaylistDetailPage({
    required this.title,
    this.playlistId,
    required this.songs,
    this.isSmart = false,
    required this.playbackController,
    this.repository,
  });

  @override
  State<_PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<_PlaylistDetailPage> {
  late List<Song> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = List.from(widget.songs);
    if (_tracks.isNotEmpty) {
      YouTubeStreamService.instance.prewarmSongs(_tracks.take(15).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDurationMs = _tracks.fold<int>(0, (sum, s) => sum + s.durationMs);
    final totalMinutes = (totalDurationMs / 60000).round();

    return ValueListenableBuilder<PlaybackStateModel>(
      valueListenable: widget.playbackController,
      builder: (context, playbackState, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(widget.title, style: AppTypography.headingSmall),
          ),
          bottomNavigationBar: playbackState.currentSong != null
              ? SafeArea(
                  top: false,
                  child: MiniPlayer(
                    playbackState: playbackState,
                    controller: widget.playbackController,
                  ),
                )
              : null,
          body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DeterministicArtwork(seed: widget.title, size: 76),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: AppTypography.headingMedium),
                      Text('${_tracks.length} tracks • $totalMinutes mins', style: AppTypography.caption),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.background,
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Play'),
                            onPressed: () {
                              if (_tracks.isNotEmpty) {
                                widget.playbackController.playSong(
                                  _tracks.first,
                                  PlaybackContext(
                                    type: PlaybackContextType.playlist,
                                    id: widget.playlistId ?? widget.title,
                                    name: widget.title,
                                  ),
                                  _tracks,
                                  shuffleEnabled: false,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                            ),
                            icon: const Icon(Icons.shuffle_rounded),
                            label: const Text('Shuffle'),
                            onPressed: () {
                              if (_tracks.isNotEmpty) {
                                widget.playbackController.playSong(
                                  _tracks.first,
                                  PlaybackContext(
                                    type: PlaybackContextType.playlist,
                                    id: widget.playlistId ?? widget.title,
                                    name: widget.title,
                                  ),
                                  _tracks,
                                  shuffleEnabled: true,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.divider),
          Expanded(
            child: _tracks.isEmpty
                ? Center(child: Text('Playlist is empty.', style: AppTypography.caption))
                : ReorderableListView.builder(
                    itemCount: _tracks.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) newIndex -= 1;
                        final item = _tracks.removeAt(oldIndex);
                        _tracks.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final song = _tracks[index];
                      return ListTile(
                        key: ValueKey(song.id),
                        leading: SongArtwork(
                          song: song,
                          size: 40,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(song.title, style: AppTypography.songTitle, maxLines: 1),
                            ),
                            if (song.isOnline)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.stream_rounded, size: 10, color: AppColors.primary),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Stream',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHighlight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded, size: 10, color: AppColors.textSecondary),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Offline',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text('${song.artist} • ${song.formattedDuration}', style: AppTypography.caption),
                        trailing: widget.isSmart
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                                onPressed: () async {
                                  if (widget.playlistId != null && widget.repository != null) {
                                    await widget.repository!.removeSongFromPlaylist(widget.playlistId!, song.id);
                                    setState(() => _tracks.removeAt(index));
                                  }
                                },
                              ),
                        onTap: () {
                          widget.playbackController.playSong(
                            song,
                            PlaybackContext(
                              type: PlaybackContextType.playlist,
                              id: widget.playlistId ?? widget.title,
                              name: widget.title,
                            ),
                            _tracks,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
      },
    );
  }
}
