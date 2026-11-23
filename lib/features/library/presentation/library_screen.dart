import 'package:flutter/material.dart';
import '../../../core/models/album.dart';
import '../../../core/models/artist.dart';
import '../../../core/models/playback_context.dart';
import '../../../core/models/song.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/deterministic_artwork.dart';
import '../../../core/widgets/playing_equalizer_bars.dart';
import '../../../core/widgets/song_artwork.dart';
import '../../audio/domain/playback_state_model.dart';
import '../../audio/presentation/playback_controller.dart';
import '../domain/music_repository.dart';

enum LibrarySortOption {
  title,
  artist,
  album,
  duration,
  dateAdded,
  recentlyPlayed,
}

class LibraryScreen extends StatefulWidget {
  final MusicRepository repository;
  final PlaybackController playbackController;

  const LibraryScreen({
    super.key,
    required this.repository,
    required this.playbackController,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Song> _allSongs = [];
  List<Album> _allAlbums = [];
  List<Artist> _allArtists = [];
  List<String> _allFolders = [];
  List<String> _allGenres = [];

  bool _isLoading = true;
  String _searchQuery = '';
  LibrarySortOption _sortOption = LibrarySortOption.title;
  bool _sortAscending = true;

  // Multi-select mode
  bool _isMultiSelect = false;
  final Set<String> _selectedSongIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadLibraryData();
  }

  Future<void> _loadLibraryData() async {
    setState(() => _isLoading = true);
    final songs = await widget.repository.getAllSongs();
    final albums = await widget.repository.getAlbums();
    final artists = await widget.repository.getArtists();
    final folders = await widget.repository.getFolders();
    final genres = await widget.repository.getGenres();

    if (mounted) {
      setState(() {
        _allSongs = songs;
        _allAlbums = albums;
        _allArtists = artists;
        _allFolders = folders;
        _allGenres = genres;
        _isLoading = false;
      });
    }
  }

  List<Song> _getFilteredAndSortedSongs() {
    var list = _allSongs;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) {
        return s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.album.toLowerCase().contains(q) ||
            (s.genre?.toLowerCase().contains(q) ?? false) ||
            s.folder.toLowerCase().contains(q);
      }).toList();
    }

    list = List.from(list);
    list.sort((a, b) {
      int cmp;
      switch (_sortOption) {
        case LibrarySortOption.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case LibrarySortOption.artist:
          cmp = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
          break;
        case LibrarySortOption.album:
          cmp = a.album.toLowerCase().compareTo(b.album.toLowerCase());
          break;
        case LibrarySortOption.duration:
          cmp = a.durationMs.compareTo(b.durationMs);
          break;
        case LibrarySortOption.dateAdded:
          final d1 = a.dateAdded ?? DateTime(1970);
          final d2 = b.dateAdded ?? DateTime(1970);
          cmp = d1.compareTo(d2);
          break;
        case LibrarySortOption.recentlyPlayed:
          final p1 = a.lastPlayed ?? DateTime(1970);
          final p2 = b.lastPlayed ?? DateTime(1970);
          cmp = p1.compareTo(p2);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    return list;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
        title: _isMultiSelect
            ? Text('${_selectedSongIds.length} Selected', style: AppTypography.headingSmall)
            : Text('Library', style: AppTypography.headingMedium),
        actions: [
          if (_isMultiSelect) ...[
            IconButton(
              icon: const Icon(Icons.select_all_rounded),
              tooltip: 'Select All',
              onPressed: () {
                setState(() {
                  _selectedSongIds.addAll(_allSongs.map((s) => s.id));
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.playlist_add_rounded),
              tooltip: 'Add to Playlist',
              onPressed: _addSelectedToPlaylist,
            ),
            IconButton(
              icon: Icon(Icons.favorite_rounded, color: AppColors.primary),
              tooltip: 'Add to Favorites',
              onPressed: _addSelectedToFavorites,
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                setState(() {
                  _isMultiSelect = false;
                  _selectedSongIds.clear();
                });
              },
            ),
          ] else ...[
            PopupMenuButton<LibrarySortOption>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: 'Sort By',
              onSelected: (opt) {
                if (_sortOption == opt) {
                  setState(() => _sortAscending = !_sortAscending);
                } else {
                  setState(() {
                    _sortOption = opt;
                    _sortAscending = true;
                  });
                }
              },
              itemBuilder: (context) => [
                _sortMenuItem(LibrarySortOption.title, 'Title'),
                _sortMenuItem(LibrarySortOption.artist, 'Artist'),
                _sortMenuItem(LibrarySortOption.album, 'Album'),
                _sortMenuItem(LibrarySortOption.duration, 'Duration'),
                _sortMenuItem(LibrarySortOption.dateAdded, 'Date Added'),
                _sortMenuItem(LibrarySortOption.recentlyPlayed, 'Recently Played'),
              ],
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Songs'),
            Tab(text: 'Albums'),
            Tab(text: 'Artists'),
            Tab(text: 'Folders'),
            Tab(text: 'Genres'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Instant Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Search songs, albums, artists...',
                      hintStyle: AppTypography.caption,
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.divider, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSongsTab(),
                      _buildAlbumsTab(),
                      _buildArtistsTab(),
                      _buildFoldersTab(),
                      _buildGenresTab(),
                    ],
                  ),
                ),
              ],
            ),
        );
      },
    );
  }

  PopupMenuItem<LibrarySortOption> _sortMenuItem(LibrarySortOption opt, String label) {
    final isSelected = _sortOption == opt;
    return PopupMenuItem(
      value: opt,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary)),
          if (isSelected)
            Icon(
              _sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 16,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  // --- 1. Songs Tab ---
  Widget _buildSongsTab() {
    final songs = _getFilteredAndSortedSongs();
    if (songs.isEmpty) {
      return Center(
        child: Text('No songs found.', style: AppTypography.caption),
      );
    }

    return ValueListenableBuilder<PlaybackStateModel>(
      valueListenable: widget.playbackController,
      builder: (context, playbackState, child) {
        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            final isPlayingThis = (playbackState.currentSong?.id == song.id);
            final isSelected = _selectedSongIds.contains(song.id);

            return Container(
              decoration: BoxDecoration(
                border: isPlayingThis
                    ? Border(
                        left: BorderSide(color: AppColors.primary, width: 3.5),
                      )
                    : null,
                color: isSelected ? AppColors.surfaceHighlight : Colors.transparent,
              ),
              child: ListTile(
                leading: SongArtwork(
                  song: song,
                  size: 48,
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Row(
                  children: [
                    if (isPlayingThis && playbackState.isPlaying) ...[
                      const PlayingEqualizerBars(size: 14),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        song.title,
                        style: AppTypography.songTitle.copyWith(
                          color: isPlayingThis ? AppColors.primary : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  '${song.artist} • ${song.formattedDuration}',
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: _isMultiSelect
                    ? Checkbox(
                        value: isSelected,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedSongIds.add(song.id);
                            } else {
                              _selectedSongIds.remove(song.id);
                            }
                          });
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        onPressed: () => _showSongMenu(song, songs),
                      ),
                onTap: () {
                  if (_isMultiSelect) {
                    setState(() {
                      if (isSelected) {
                        _selectedSongIds.remove(song.id);
                      } else {
                        _selectedSongIds.add(song.id);
                      }
                    });
                  } else {
                    widget.playbackController.playSong(
                      song,
                      PlaybackContext.library,
                      songs,
                    );
                  }
                },
                onLongPress: () {
                  setState(() {
                    _isMultiSelect = true;
                    _selectedSongIds.add(song.id);
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- 2. Albums Tab ---
  Widget _buildAlbumsTab() {
    var albums = _allAlbums;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      albums = albums.where((a) => a.title.toLowerCase().contains(q) || a.artist.toLowerCase().contains(q)).toList();
    }

    if (albums.isEmpty) return Center(child: Text('No albums found.', style: AppTypography.caption));

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return GestureDetector(
          onTap: () => _openAlbumDetail(album),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DeterministicArtwork(seed: '${album.title} ${album.artist}', size: 200),
                ),
              ),
              const SizedBox(height: 6),
              Text(album.title, style: AppTypography.songTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${album.artist} • ${album.trackCount} tracks', style: AppTypography.caption, maxLines: 1),
            ],
          ),
        );
      },
    );
  }

  // --- 3. Artists Tab ---
  Widget _buildArtistsTab() {
    var artists = _allArtists;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      artists = artists.where((a) => a.name.toLowerCase().contains(q)).toList();
    }

    if (artists.isEmpty) return Center(child: Text('No artists found.', style: AppTypography.caption));

    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.surfaceHighlight,
            child: Text(artist.name.isNotEmpty ? artist.name[0].toUpperCase() : '?',
                style: TextStyle(color: AppColors.primary)),
          ),
          title: Text(artist.name, style: AppTypography.songTitle),
          subtitle: Text('${artist.trackCount} tracks • ${artist.albumCount} albums', style: AppTypography.caption),
          onTap: () => _openArtistDetail(artist),
        );
      },
    );
  }

  // --- 4. Folders Tab ---
  Widget _buildFoldersTab() {
    var folders = _allFolders;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      folders = folders.where((f) => f.toLowerCase().contains(q)).toList();
    }

    if (folders.isEmpty) return Center(child: Text('No folders found.', style: AppTypography.caption));

    return ListView.builder(
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        return ListTile(
          leading: Icon(Icons.folder_rounded, color: AppColors.primary),
          title: Text(folder, style: AppTypography.songTitle),
          onTap: () => _openFolderDetail(folder),
        );
      },
    );
  }

  // --- 5. Genres Tab ---
  Widget _buildGenresTab() {
    var genres = _allGenres;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      genres = genres.where((g) => g.toLowerCase().contains(q)).toList();
    }

    if (genres.isEmpty) return Center(child: Text('No genres found.', style: AppTypography.caption));

    return ListView.builder(
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        return ListTile(
          leading: Icon(Icons.category_rounded, color: AppColors.primary),
          title: Text(genre, style: AppTypography.songTitle),
          onTap: () async {
            final songs = await widget.repository.getSongsByGenre(genre);
            _openSubcollectionDetail(genre, 'Genre', songs);
          },
        );
      },
    );
  }

  // --- 3-Dot Song Menu ---
  void _showSongMenu(Song song, List<Song> contextTracks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: SongArtwork(
                  song: song,
                  size: 40,
                  borderRadius: BorderRadius.circular(6),
                ),
                title: Text(song.title, style: AppTypography.songTitle),
                subtitle: Text(song.artist, style: AppTypography.caption),
              ),
              Divider(color: AppColors.divider),
              ListTile(
                leading: Icon(Icons.play_arrow_rounded, color: AppColors.primary),
                title: const Text('Play Now'),
                onTap: () {
                  Navigator.pop(context);
                  widget.playbackController.playSong(song, PlaybackContext.library, contextTracks);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_play_rounded),
                title: const Text('Play Next'),
                onTap: () {
                  Navigator.pop(context);
                  widget.playbackController.playNext(song);
                  _showFeedback('Added to play next.');
                },
              ),
              ListTile(
                leading: const Icon(Icons.queue_rounded),
                title: const Text('Add to Queue'),
                onTap: () {
                  Navigator.pop(context);
                  widget.playbackController.addToQueue(song);
                  _showFeedback('Added to queue.');
                },
              ),
              ListTile(
                leading: Icon(
                  song.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: song.isFavorite ? AppColors.primary : AppColors.textPrimary,
                ),
                title: Text(song.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                onTap: () async {
                  Navigator.pop(context);
                  await widget.repository.toggleFavorite(song.id, !song.isFavorite);
                  _loadLibraryData();
                  _showFeedback(song.isFavorite ? 'Removed from favorites' : 'Added to favorites');
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded),
                title: const Text('Add to Playlist'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddToPlaylistDialog([song.id]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // --- Add to Playlist Dialog ---
  void _showAddToPlaylistDialog(List<String> songIds) async {
    final playlists = await widget.repository.getAllPlaylists();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: Text('Add to Playlist', style: AppTypography.headingSmall),
          content: playlists.isEmpty
              ? const Text('No playlists created yet.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final pl = playlists[index];
                      return ListTile(
                        leading: Icon(Icons.queue_music_rounded, color: AppColors.primary),
                        title: Text(pl.name, style: AppTypography.songTitle),
                        onTap: () async {
                          for (final id in songIds) {
                            await widget.repository.addSongToPlaylist(pl.id, id);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            _showFeedback('Added to ${pl.name}.');
                          }
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addSelectedToPlaylist() {
    _showAddToPlaylistDialog(_selectedSongIds.toList());
  }

  void _addSelectedToFavorites() async {
    for (final id in _selectedSongIds) {
      await widget.repository.toggleFavorite(id, true);
    }
    setState(() {
      _isMultiSelect = false;
      _selectedSongIds.clear();
    });
    _loadLibraryData();
    _showFeedback('Added selected songs to favorites.');
  }

  void _openAlbumDetail(Album album) async {
    final songs = await widget.repository.getSongsByAlbum(album.title);
    _openSubcollectionDetail(album.title, album.artist, songs);
  }

  void _openArtistDetail(Artist artist) async {
    final songs = await widget.repository.getSongsByArtist(artist.name);
    _openSubcollectionDetail(artist.name, '${songs.length} songs', songs);
  }

  void _openFolderDetail(String folder) async {
    final songs = await widget.repository.getSongsByFolder(folder);
    _openSubcollectionDetail(folder, 'Folder', songs);
  }

  void _openSubcollectionDetail(String title, String subtitle, List<Song> songs) {
    Navigator.of(context).push(
      MaterialAppRoute(
        builder: (context) => _SubcollectionDetailScreen(
          title: title,
          subtitle: subtitle,
          songs: songs,
          playbackController: widget.playbackController,
        ),
      ),
    );
  }
}

class _SubcollectionDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Song> songs;
  final PlaybackController playbackController;

  const _SubcollectionDetailScreen({
    required this.title,
    required this.subtitle,
    required this.songs,
    required this.playbackController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
        title: Text(title, style: AppTypography.headingSmall),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DeterministicArtwork(seed: title, size: 80),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.headingMedium),
                      Text(subtitle, style: AppTypography.caption),
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
                              if (songs.isNotEmpty) {
                                playbackController.playSong(
                                  songs.first,
                                  PlaybackContext(type: PlaybackContextType.album, id: title, name: title),
                                  songs,
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
                              if (songs.isNotEmpty) {
                                playbackController.playSong(
                                  songs.first,
                                  PlaybackContext(type: PlaybackContextType.album, id: title, name: title),
                                  songs,
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
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  leading: Text('${index + 1}', style: AppTypography.caption),
                  title: Text(song.title, style: AppTypography.songTitle),
                  subtitle: Text('${song.artist} • ${song.formattedDuration}', style: AppTypography.caption),
                  onTap: () {
                    playbackController.playSong(
                      song,
                      PlaybackContext(type: PlaybackContextType.album, id: title, name: title),
                      songs,
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

class MaterialAppRoute<T> extends MaterialPageRoute<T> {
  MaterialAppRoute({required super.builder});
}
