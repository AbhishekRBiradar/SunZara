import 'package:flutter/material.dart' hide RepeatMode;
import '../../../core/models/playback_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/song_artwork.dart';
import '../../audio/domain/playback_state_model.dart';
import '../../audio/presentation/playback_controller.dart';
import '../domain/lyrics_parser.dart';
import '../domain/sleep_timer.dart';
import 'equalizer_controller.dart';
import 'widgets/visualizer_widget.dart';

class NowPlayingScreen extends StatefulWidget {
  final PlaybackStateModel playbackState;
  final PlaybackController controller;

  const NowPlayingScreen({
    super.key,
    required this.playbackState,
    required this.controller,
  });

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  late final EqualizerController _equalizerController;
  late final SleepTimerController _sleepTimerController;

  VisualizerMode _visualizerMode = VisualizerMode.bars;
  bool _showVisualizer = false;

  LyricsData _lyricsData = LyricsData.empty();
  bool _isLoadingLyrics = false;

  bool _isSlidingNext = true;
  double _dragOffsetY = 0.0;

  @override
  void initState() {
    super.initState();
    _equalizerController = EqualizerController();
    _sleepTimerController = SleepTimerController(widget.controller);

    if (widget.playbackState.audioSessionId != null) {
      _equalizerController.initAudioSession(widget.playbackState.audioSessionId);
    }

    _loadLyrics();
  }

  void _triggerNext() {
    setState(() => _isSlidingNext = true);
    widget.controller.next();
  }

  void _triggerPrevious() {
    setState(() => _isSlidingNext = false);
    widget.controller.previous();
  }

  Widget _buildSlideTransition(Widget child, Animation<double> animation) {
    final inOffset = Tween<Offset>(
      begin: Offset(_isSlidingNext ? 1.0 : -1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    final outOffset = Tween<Offset>(
      begin: Offset(_isSlidingNext ? -1.0 : 1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInCubic,
    ));

    return ClipRect(
      child: SlideTransition(
        position: animation.status == AnimationStatus.reverse ? outOffset : inOffset,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  void _loadLyrics() async {
    final song = widget.playbackState.currentSong;
    if (song == null || song.lrcPath == null) {
      setState(() => _lyricsData = LyricsData.empty());
      return;
    }

    setState(() => _isLoadingLyrics = true);
    final lyrics = await LyricsData.fromFile(song.lrcPath!);
    if (mounted) {
      setState(() {
        _lyricsData = lyrics;
        _isLoadingLyrics = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant NowPlayingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playbackState.currentSong?.id !=
        widget.playbackState.currentSong?.id) {
      _loadLyrics();
    }
  }

  @override
  void dispose() {
    _equalizerController.dispose();
    _sleepTimerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlaybackStateModel>(
      valueListenable: widget.controller,
      builder: (context, state, child) {
        final song = state.currentSong;
        if (song == null) {
          return const Scaffold(
            body: Center(child: Text('No song playing')),
          );
        }

        final durationMs = state.duration.inMilliseconds > 0
            ? state.duration.inMilliseconds
            : song.durationMs;
        final currentPosMs = state.position.inMilliseconds.clamp(0, durationMs);

        final elapsedMinutes = (currentPosMs / 60000).floor();
        final elapsedSeconds = ((currentPosMs % 60000) / 1000).floor();
        final totalMinutes = (durationMs / 60000).floor();
        final totalSeconds = ((durationMs % 60000) / 1000).floor();

        final elapsedStr =
            '$elapsedMinutes:${elapsedSeconds.toString().padLeft(2, '0')}';
        final totalStr =
            '$totalMinutes:${totalSeconds.toString().padLeft(2, '0')}';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              children: [
                Text(
                  'PLAYING FROM',
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  state.context.name,
                  style: AppTypography.headingSmall.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () => _showSongDetailsSheet(song),
              ),
            ],
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > 0 || _dragOffsetY > 0) {
                setState(() {
                  _dragOffsetY = (_dragOffsetY + details.delta.dy).clamp(0.0, 320.0);
                });
              }
            },
            onVerticalDragEnd: (details) {
              if (_dragOffsetY > 90 || (details.primaryVelocity ?? 0) > 280) {
                Navigator.of(context).pop();
              } else {
                setState(() {
                  _dragOffsetY = 0.0;
                });
              }
            },
            onVerticalDragCancel: () {
              setState(() {
                _dragOffsetY = 0.0;
              });
            },
            onHorizontalDragEnd: (details) {
              final vel = details.primaryVelocity ?? 0;
              if (vel < -200) {
                // Swipe Left -> Next Track
                _triggerNext();
              } else if (vel > 200) {
                // Swipe Right -> Previous Track
                _triggerPrevious();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(0, _dragOffsetY, 0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Artwork container with sliding transition & subtle glow
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        transitionBuilder: _buildSlideTransition,
                        child: Container(
                          key: ValueKey('art_${song.id}'),
                          width: 290,
                          height: 290,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(50),
                                blurRadius: 36,
                                spreadRadius: 4,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                SongArtwork(
                                  song: song,
                                  size: 290,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                if (_showVisualizer)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: VisualizerWidget(
                                      mode: _visualizerMode,
                                      isPlaying: state.isPlaying,
                                      height: 80,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title, Artist with sliding animation, and Favorite Heart
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            transitionBuilder: _buildSlideTransition,
                            child: Column(
                              key: ValueKey('info_${song.id}'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: AppTypography.headingMedium.copyWith(fontSize: 22),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  song.artist,
                                  style: AppTypography.artistSubtitle.copyWith(fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            song.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: song.isFavorite ? AppColors.primary : AppColors.textSecondary,
                            size: 28,
                          ),
                          onPressed: () => widget.controller.toggleFavorite(),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Waveform Scrubber
                  Slider(
                    value: currentPosMs.toDouble(),
                    min: 0,
                    max: durationMs.toDouble(),
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.divider,
                    onChanged: (val) {
                      widget.controller.seek(Duration(milliseconds: val.round()));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(elapsedStr, style: AppTypography.timestamp),
                        Text(totalStr, style: AppTypography.timestamp),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main Playback Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Shuffle toggle (Teal when ON)
                      IconButton(
                        icon: Icon(
                          Icons.shuffle_rounded,
                          color: state.isShuffleEnabled
                              ? AppColors.primary
                              : AppColors.textMuted,
                          size: 26,
                        ),
                        onPressed: () => widget.controller.toggleShuffle(),
                      ),
                      // Previous button
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          color: AppColors.textPrimary,
                          size: 38,
                        ),
                        onPressed: _triggerPrevious,
                      ),
                      // Prominent Teal Play/Pause button (56px)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(90),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            state.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.background,
                            size: 36,
                          ),
                          onPressed: () => widget.controller.togglePlayPause(),
                        ),
                      ),
                      // Next button
                      IconButton(
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.textPrimary,
                          size: 38,
                        ),
                        onPressed: _triggerNext,
                      ),
                      // Repeat cycle toggle
                      IconButton(
                        icon: Icon(
                          switch (state.repeatMode) {
                            RepeatMode.off => Icons.repeat_rounded,
                            RepeatMode.all => Icons.repeat_rounded,
                            RepeatMode.one => Icons.repeat_one_rounded,
                          },
                          color: state.repeatMode != RepeatMode.off
                              ? AppColors.primary
                              : AppColors.textMuted,
                          size: 26,
                        ),
                        onPressed: () => widget.controller.cycleRepeatMode(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Secondary feature bar: Queue, Lyrics, Equalizer, Visualizer, Sleep Timer, Speed
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomPill(
                        icon: Icons.queue_music_rounded,
                        label: 'Queue',
                        badge: state.fullUpcomingQueue.isNotEmpty
                            ? state.fullUpcomingQueue.length.toString()
                            : null,
                        onTap: () => _showQueueSheet(state),
                      ),
                      _buildBottomPill(
                        icon: Icons.lyrics_rounded,
                        label: 'Lyrics',
                        onTap: () => _showLyricsSheet(song, state.position),
                      ),
                      _buildBottomPill(
                        icon: Icons.equalizer_rounded,
                        label: 'EQ',
                        onTap: () => _showEqualizerSheet(),
                      ),
                      _buildBottomPill(
                        icon: Icons.graphic_eq_rounded,
                        label: 'Visualizer',
                        isActive: _showVisualizer,
                        onTap: () => _showVisualizerSheet(),
                      ),
                      _buildBottomPill(
                        icon: Icons.timer_outlined,
                        label: 'Timer',
                        onTap: () => _showSleepTimerSheet(),
                      ),
                      _buildBottomPill(
                        icon: Icons.speed_rounded,
                        label: '${state.speed}x',
                        onTap: () => _showSpeedDialog(state.speed),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildBottomPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.surfaceHighlight : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.divider,
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              if (badge != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // --- Queue Sheet ---
  void _showQueueSheet(PlaybackStateModel state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final upcoming = state.fullUpcomingQueue;

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Up Next (${upcoming.length})',
                            style: AppTypography.headingSmall,
                          ),
                          if (upcoming.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                widget.controller.clearUpcoming();
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Clear Upcoming',
                                style: AppTypography.button.copyWith(
                                  color: AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.divider),
                    if (upcoming.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            'Queue is empty.',
                            style: AppTypography.caption,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ReorderableListView.builder(
                          scrollController: scrollController,
                          itemCount: upcoming.length,
                          onReorder: (oldIndex, newIndex) {
                            if (oldIndex < state.manualQueue.length) {
                              widget.controller.reorderManualQueue(oldIndex, newIndex);
                            } else {
                              final autoOld = oldIndex - state.manualQueue.length;
                              final autoNew = newIndex - state.manualQueue.length;
                              widget.controller.reorderAutomaticPool(autoOld, autoNew);
                            }
                            setSheetState(() {});
                          },
                          itemBuilder: (context, index) {
                            final item = upcoming[index];
                            return ListTile(
                              key: ValueKey(item.queueId),
                              leading: SongArtwork(
                                song: item.song,
                                size: 40,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              title: Text(
                                item.song.title,
                                style: AppTypography.songTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${item.song.artist} • ${item.isManual ? "Manual Queue" : "Auto Shuffle"}',
                                style: AppTypography.caption,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () {
                                  widget.controller.removeFromQueue(item.queueId);
                                  setSheetState(() {});
                                },
                              ),
                              onTap: () {
                                widget.controller.playTrackAtIndex(index);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // --- Lyrics Sheet ---
  void _showLyricsSheet(dynamic song, Duration currentPosition) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            if (_isLoadingLyrics) {
              return Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (_lyricsData.lines.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_off_rounded, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text('No offline lyrics available', style: AppTypography.headingSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Place a .lrc file in the same folder as the audio track with the same filename to view synchronized lyrics.',
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final activeIdx = _lyricsData.getActiveLineIndex(currentPosition);

            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text('Lyrics', style: AppTypography.headingSmall),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    itemCount: _lyricsData.lines.length,
                    itemBuilder: (context, index) {
                      final line = _lyricsData.lines[index];
                      final isCurrent = (index == activeIdx);

                      return GestureDetector(
                        onTap: () {
                          if (_lyricsData.isSynced) {
                            widget.controller.seek(line.timestamp);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            line.text,
                            style: isCurrent
                                ? AppTypography.headingMedium.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )
                                : AppTypography.body.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 15,
                                  ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Equalizer Sheet ---
  void _showEqualizerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ValueListenableBuilder<EqualizerState>(
          valueListenable: _equalizerController,
          builder: (context, eqState, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Equalizer', style: AppTypography.headingMedium),
                      Switch(
                        value: eqState.isEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (val) => _equalizerController.setEnabled(val),
                      ),
                    ],
                  ),
                  Divider(color: AppColors.divider),
                  if (eqState.bands.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Equalizer not available for this session.'),
                    )
                  else ...[
                    // Band sliders
                    SizedBox(
                      height: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: eqState.bands.map((band) {
                          return Column(
                            children: [
                              Text(band.formattedDb, style: AppTypography.caption),
                              Expanded(
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Slider(
                                    value: band.level.toDouble(),
                                    min: band.minLevel.toDouble(),
                                    max: band.maxLevel.toDouble(),
                                    activeColor: AppColors.primary,
                                    inactiveColor: AppColors.divider,
                                    onChanged: eqState.isEnabled
                                        ? (v) => _equalizerController.setBandLevel(
                                            band.index, v.round())
                                        : null,
                                  ),
                                ),
                              ),
                              Text(band.formattedFreq, style: AppTypography.caption),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Bass Boost slider
                    Row(
                      children: [
                        Icon(Icons.speaker_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Bass Boost', style: AppTypography.body),
                        Expanded(
                          child: Slider(
                            value: eqState.bassBoostStrength.toDouble(),
                            min: 0,
                            max: 1000,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.divider,
                            onChanged: eqState.isEnabled
                                ? (v) => _equalizerController.setBassBoost(v.round())
                                : null,
                          ),
                        ),
                        Text('${(eqState.bassBoostStrength / 10).round()}%',
                            style: AppTypography.caption),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Visualizer Sheet ---
  void _showVisualizerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Visualizer Settings', style: AppTypography.headingSmall),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text('Show Visualizer', style: AppTypography.body),
                value: _showVisualizer,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _showVisualizer = val);
                  Navigator.pop(context);
                },
              ),
              Divider(color: AppColors.divider),
              Wrap(
                spacing: 8,
                children: VisualizerMode.values.map((mode) {
                  final isSelected = (_visualizerMode == mode);
                  return ChoiceChip(
                    label: Text(mode.name.toUpperCase()),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    onSelected: (val) {
                      setState(() {
                        _visualizerMode = mode;
                        _showVisualizer = true;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Sleep Timer Sheet ---
  void _showSleepTimerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = [
          {'label': '15 Minutes', 'dur': const Duration(minutes: 15)},
          {'label': '30 Minutes', 'dur': const Duration(minutes: 30)},
          {'label': '45 Minutes', 'dur': const Duration(minutes: 45)},
          {'label': '60 Minutes', 'dur': const Duration(minutes: 60)},
        ];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sleep Timer', style: AppTypography.headingSmall),
              const SizedBox(height: 12),
              ...options.map((opt) {
                return ListTile(
                  title: Text(opt['label'] as String, style: AppTypography.body),
                  onTap: () {
                    _sleepTimerController.setTimer(opt['dur'] as Duration);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sleep timer set for ${opt['label']}')),
                    );
                  },
                );
              }),
              ListTile(
                title: Text('End of Track', style: AppTypography.body),
                onTap: () {
                  _sleepTimerController.setEndOfTrack();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playback will pause at end of track.')),
                  );
                },
              ),
              if (_sleepTimerController.state.isActive)
                ListTile(
                  title: Text('Cancel Active Timer',
                      style: AppTypography.body.copyWith(color: AppColors.error)),
                  onTap: () {
                    _sleepTimerController.cancel();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // --- Speed Dialog ---
  void _showSpeedDialog(double currentSpeed) {
    const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: Text('Playback Speed', style: AppTypography.headingSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: speeds.map((s) {
              return RadioListTile<double>(
                value: s,
                groupValue: currentSpeed,
                activeColor: AppColors.primary,
                title: Text('${s}x', style: AppTypography.body),
                onChanged: (val) {
                  if (val != null) {
                    widget.controller.setSpeed(val);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // --- Song Details Sheet ---
  void _showSongDetailsSheet(dynamic song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Song Details', style: AppTypography.headingSmall),
              Divider(color: AppColors.divider),
              _detailRow('Title', song.title),
              _detailRow('Artist', song.artist),
              _detailRow('Album', song.album),
              _detailRow('Duration', song.formattedDuration),
              _detailRow('File Size', '${(song.fileSize / (1024 * 1024)).toStringAsFixed(2)} MB'),
              _detailRow('File Path', song.filePath),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTypography.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
