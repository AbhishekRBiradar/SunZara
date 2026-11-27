import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/playback_context.dart';
import '../../../core/models/song.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/playing_equalizer_bars.dart';
import '../../../core/widgets/song_artwork.dart';
import '../../audio/domain/playback_state_model.dart';
import '../../audio/domain/youtube_stream_service.dart';
import '../../audio/presentation/playback_controller.dart';
import '../../library/domain/music_repository.dart';
import '../../now_playing/presentation/widgets/mini_player.dart';
import '../domain/voice_search_service.dart';

/// Dedicated screen to search and stream songs from online music catalog.
class OnlineSearchScreen extends StatefulWidget {
  final MusicRepository repository;
  final PlaybackController playbackController;
  final String? initialQuery;
  final bool startVoiceSearch;
  @visibleForTesting
  final List<Song>? initialResults;

  const OnlineSearchScreen({
    super.key,
    required this.repository,
    required this.playbackController,
    this.initialQuery,
    this.startVoiceSearch = false,
    this.initialResults,
  });

  @override
  State<OnlineSearchScreen> createState() => _OnlineSearchScreenState();
}

class _OnlineSearchScreenState extends State<OnlineSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _suggestDebounce;
  Timer? _searchDebounce;
  List<String> _suggestions = [];
  late List<Song> _results = List<Song>.from(widget.initialResults ?? const []);
  bool _isSearching = false;
  late bool _hasSearched = widget.initialResults != null;
  String? _errorMessage;
  String? _lastShownPlaybackError;
  int _suggestGeneration = 0;
  int _searchGeneration = 0;

  static const List<String> _quickSuggestions = [
    'Arijit Singh',
    'Kesariya',
    'Atif Aslam',
    'Lo-fi Beats',
    'The Weeknd',
    'Punjabi Hits',
    'Shreya Ghoshal',
    '90s Bollywood',
  ];

  bool _isVoiceListening = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isNotEmpty) {
      _searchController.text = initial;
      _performSearch(initial);
    } else if (widget.startVoiceSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startVoiceSearch();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  Future<void> _startVoiceSearch() async {
    if (_isVoiceListening) return;
    setState(() => _isVoiceListening = true);
    try {
      final spoken = await VoiceSearchService.instance.listenForQuery(
        context: context,
        playbackController: widget.playbackController,
      );
      if (!mounted) return;
      if (spoken != null && spoken.isNotEmpty) {
        _searchController.text = spoken;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: spoken.length),
        );
        _focusNode.unfocus();
        await _performSearch(spoken, clearSuggestions: true);
      }
    } on VoiceSearchUnavailableException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isVoiceListening = false);
      }
    }
  }

  @override
  void dispose() {
    _suggestDebounce?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _suggestDebounce?.cancel();
    _searchDebounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _suggestions = [];
        _results = [];
        _isSearching = false;
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    if (trimmed.length >= 3) {
      // Fetch fast autocomplete suggestions immediately (~150ms)
      _suggestDebounce = Timer(const Duration(milliseconds: 160), () {
        _fetchSuggestions(trimmed);
      });
      // Also auto-load matching songs if user pauses typing
      _searchDebounce = Timer(const Duration(milliseconds: 750), () {
        _performSearch(trimmed);
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    final gen = ++_suggestGeneration;
    final items = await YouTubeStreamService.instance.fetchSearchSuggestions(query);
    if (!mounted || gen != _suggestGeneration) return;
    setState(() {
      _suggestions = items;
    });
  }

  Future<void> _performSearch(String query, {bool clearSuggestions = false}) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    _suggestDebounce?.cancel();
    _searchDebounce?.cancel();

    final gen = ++_searchGeneration;
    setState(() {
      if (clearSuggestions) _suggestions = [];
      _isSearching = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final songs = await YouTubeStreamService.instance.searchOnlineSongs(clean, limit: 25);
      if (!mounted || gen != _searchGeneration) return;
      setState(() {
        _results = songs;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted || gen != _searchGeneration) return;
      setState(() {
        _isSearching = false;
        _errorMessage = 'Could not fetch online songs. Check your internet connection.';
      });
    }
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    _focusNode.unfocus();
    _performSearch(suggestion, clearSuggestions: true);
  }

  void _playOnlineSong(Song song) {
    widget.playbackController.playSong(
      song,
      const PlaybackContext(
        type: PlaybackContextType.search,
        id: 'online_search',
        name: 'Online Search',
      ),
      [song],
    );
  }

  Future<void> _showSongOptions(Song song) async {
    final existing = await widget.repository.getSongById(song.id);
    final isCurrentlyPlayingLiked =
        widget.playbackController.state.currentSong?.id == song.id &&
        (widget.playbackController.state.currentSong?.isFavorite ?? false);
    final isLiked = (existing?.isFavorite ?? false) || isCurrentlyPlayingLiked;
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: SongArtwork(song: song, size: 44),
                title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.songTitle),
                subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.caption),
              ),
              Divider(color: AppColors.divider),
              ListTile(
                leading: Icon(Icons.play_arrow_rounded, color: AppColors.primary),
                title: Text('Play Now', style: AppTypography.body),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _playOnlineSong(song);
                },
              ),
              ListTile(
                leading: Icon(Icons.playlist_play_rounded, color: AppColors.primary),
                title: Text('Play Next', style: AppTypography.body),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  widget.playbackController.playNext(song);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Playing "${song.title}" next')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.queue_music_rounded, color: AppColors.primary),
                title: Text('Add to Queue', style: AppTypography.body),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  widget.playbackController.addToQueue(song);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added "${song.title}" to queue')),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  isLiked ? 'Remove from Liked Songs' : 'Add to Liked Songs',
                  style: AppTypography.body,
                ),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  if (widget.playbackController.state.currentSong?.id == song.id) {
                    await widget.playbackController.toggleFavorite();
                  } else {
                    await widget.repository.setSongFavorite(song, !isLiked);
                  }
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isLiked
                            ? 'Removed "${song.title}" from Liked Songs'
                            : 'Added "${song.title}" to Liked Songs',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlaybackStateModel>(
      valueListenable: widget.playbackController,
      builder: (context, playbackState, _) {
        final pbErr = playbackState.errorMessage;
        if (pbErr != null && pbErr != _lastShownPlaybackError) {
          _lastShownPlaybackError = pbErr;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(pbErr),
                backgroundColor: AppColors.error,
              ),
            );
          });
        } else if (pbErr == null) {
          _lastShownPlaybackError = null;
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                style: AppTypography.body,
                onChanged: _onQueryChanged,
                onSubmitted: (val) {
                  _focusNode.unfocus();
                  _performSearch(val, clearSuggestions: true);
                },
                decoration: InputDecoration(
                  hintText: 'Search songs only (type 3+ letters or mic)...',
                  hintStyle: AppTypography.caption,
                  prefixIcon: Icon(Icons.music_note_rounded, color: AppColors.primary, size: 20),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onQueryChanged('');
                            _focusNode.requestFocus();
                          },
                        ),
                      IconButton(
                        tooltip: 'Voice Search',
                        icon: Icon(
                          Icons.mic_rounded,
                          size: 20,
                          color: _isVoiceListening ? AppColors.error : AppColors.primary,
                        ),
                        onPressed: _startVoiceSearch,
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.divider, width: 0.8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.2),
                  ),
                ),
              ),
            ),
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
              if (_suggestions.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider, width: 0.8),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.divider.withOpacity(0.4)),
                    itemBuilder: (context, idx) {
                      final suggestion = _suggestions[idx];
                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: Icon(Icons.search_rounded, size: 18, color: AppColors.primary),
                        title: Text(
                          suggestion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body.copyWith(fontSize: 13.5),
                        ),
                        trailing: Icon(Icons.north_west_rounded, size: 15, color: AppColors.textMuted),
                        onTap: () => _selectSuggestion(suggestion),
                      );
                    },
                  ),
                ),
              Expanded(child: _buildBody(playbackState)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwipeQueueBackground(Alignment alignment) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      color: AppColors.primary.withAlpha(45),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            Icon(Icons.queue_music_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
          ],
          Text(
            'Add to Queue',
            style: AppTypography.button.copyWith(color: AppColors.primary),
          ),
          if (!isLeft) ...[
            const SizedBox(width: 8),
            Icon(Icons.queue_music_rounded, color: AppColors.primary),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(PlaybackStateModel playbackState) {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 14),
            Text('Searching online music...', style: AppTypography.caption),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center, style: AppTypography.body),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                onPressed: () => _performSearch(_searchController.text),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Discover & Stream Online', style: AppTypography.headingSmall),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Type at least 3 letters for live song suggestions, or tap a popular search below.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 20),
            Text('POPULAR SEARCHES', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickSuggestions.map((tag) {
                return ActionChip(
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: AppColors.divider, width: 0.8),
                  avatar: Icon(Icons.search_rounded, size: 16, color: AppColors.primary),
                  label: Text(tag, style: AppTypography.body.copyWith(fontSize: 13)),
                  onPressed: () => _selectSuggestion(tag),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_off_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('No online songs found for "${_searchController.text.trim()}"', style: AppTypography.body),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final song = _results[index];
        final isPlayingThis = playbackState.currentSong?.id == song.id;

        return Dismissible(
          key: ValueKey('search_${song.id}_$index'),
          direction: DismissDirection.horizontal,
          background: _buildSwipeQueueBackground(Alignment.centerLeft),
          secondaryBackground: _buildSwipeQueueBackground(Alignment.centerRight),
          confirmDismiss: (_) async {
            widget.playbackController.addToQueue(song);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Added "${song.title}" to queue'),
                  duration: const Duration(seconds: 2),
                ),
              );
            return false;
          },
          child: Container(
            decoration: BoxDecoration(
              border: isPlayingThis
                  ? Border(left: BorderSide(color: AppColors.primary, width: 3.5))
                  : null,
            ),
            child: ListTile(
              leading: SongArtwork(
                song: song,
                size: 50,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.songTitle.copyWith(
                        color: isPlayingThis ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isPlayingThis ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.public_rounded, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${song.artist} • ${song.formattedDuration}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                onPressed: () => _showSongOptions(song),
              ),
              onTap: () => _playOnlineSong(song),
            ),
          ),
        );
      },
    );
  }
}
