import 'package:flutter/material.dart';
import '../../../core/models/playback_context.dart';
import '../../../core/models/song.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/song_artwork.dart';
import '../../audio/presentation/playback_controller.dart';
import '../../library/domain/music_repository.dart';

class FavoritesScreen extends StatefulWidget {
  final MusicRepository repository;
  final PlaybackController playbackController;

  const FavoritesScreen({
    super.key,
    required this.repository,
    required this.playbackController,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Song> _favorites = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favs = await widget.repository.getFavoriteSongs();
    if (mounted) {
      setState(() {
        _favorites = favs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        var filtered = _favorites;
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          filtered = filtered
              .where((s) =>
                  s.title.toLowerCase().contains(q) ||
                  s.artist.toLowerCase().contains(q) ||
                  s.album.toLowerCase().contains(q))
              .toList();
        }

        return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                style: AppTypography.body,
                decoration: const InputDecoration(
                  hintText: 'Search favorites...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : Text('Favorites (${_favorites.length})', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                if (_favorites.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.background,
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Play All'),
                            onPressed: () {
                              widget.playbackController.playSong(
                                _favorites.first,
                                PlaybackContext.favorites,
                                _favorites,
                                shuffleEnabled: false,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                            ),
                            icon: const Icon(Icons.shuffle_rounded),
                            label: const Text('Shuffle'),
                            onPressed: () {
                              widget.playbackController.playSong(
                                _favorites.first,
                                PlaybackContext.favorites,
                                _favorites,
                                shuffleEnabled: true,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border_rounded, size: 56, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text('No favorite tracks yet.', style: AppTypography.headingSmall),
                              const SizedBox(height: 4),
                              Text('Tap the heart icon on any song to add it here.', style: AppTypography.caption),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final song = filtered[index];
                            return ListTile(
                              leading: SongArtwork(
                                song: song,
                                size: 48,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              title: Text(song.title, style: AppTypography.songTitle, maxLines: 1),
                              subtitle: Text('${song.artist} • ${song.formattedDuration}', style: AppTypography.caption),
                              trailing: IconButton(
                                icon: Icon(Icons.favorite_rounded, color: AppColors.primary),
                                onPressed: () async {
                                  await widget.repository.toggleFavorite(song.id, false);
                                  _loadFavorites();
                                },
                              ),
                              onTap: () {
                                widget.playbackController.playSong(
                                  song,
                                  PlaybackContext.favorites,
                                  _favorites,
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
