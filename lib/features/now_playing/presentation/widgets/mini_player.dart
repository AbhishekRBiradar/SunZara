import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/playing_equalizer_bars.dart';
import '../../../../core/widgets/song_artwork.dart';
import '../../../audio/domain/playback_state_model.dart';
import '../../../audio/presentation/playback_controller.dart';
import '../now_playing_screen.dart';

class MiniPlayer extends StatefulWidget {
  final PlaybackStateModel playbackState;
  final PlaybackController controller;

  const MiniPlayer({
    super.key,
    required this.playbackState,
    required this.controller,
  });

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  bool _isSlidingNext = true;
  String? _previousSongId;

  @override
  void didUpdateWidget(covariant MiniPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentId = widget.playbackState.currentSong?.id;
    if (currentId != null && currentId != _previousSongId) {
      _previousSongId = currentId;
    }
  }

  void _triggerNext() {
    setState(() => _isSlidingNext = true);
    widget.controller.next();
  }

  void _triggerPrevious() {
    setState(() => _isSlidingNext = false);
    widget.controller.previous();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.playbackState.currentSong;
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => NowPlayingScreen(
              playbackState: widget.playbackState,
              controller: widget.controller,
            ),
            transitionsBuilder: (context, anim, secAnim, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: anim.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 250),
            reverseTransitionDuration: const Duration(milliseconds: 250),
          ),
        );
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -150) {
          // Swipe Left -> Next song
          _triggerNext();
        } else if (velocity > 150) {
          // Swipe Right -> Previous song
          _triggerPrevious();
        }
      },
      child: Container(
        height: 66,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Thin Electric Teal progress bar
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: LinearProgressIndicator(
                value: widget.playbackState.progressFraction,
                backgroundColor: AppColors.divider.withAlpha(80),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 2.5,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    // Swipable / Animated Content (Artwork + Title & Artist)
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final inOffset = Tween<Offset>(
                            begin: Offset(_isSlidingNext ? 1.0 : -1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation);

                          final outOffset = Tween<Offset>(
                            begin: Offset(_isSlidingNext ? -1.0 : 1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation);

                          return ClipRect(
                            child: SlideTransition(
                              position: animation.status == AnimationStatus.reverse
                                  ? outOffset
                                  : inOffset,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          key: ValueKey(song.id),
                          children: [
                            // Real Album Artwork with deterministic fallback
                            SongArtwork(
                              song: song,
                              size: 46,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(width: 12),
                            // Titles & 3-bar indicator
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (widget.playbackState.isPlaying) ...[
                                        const PlayingEqualizerBars(size: 12),
                                        const SizedBox(width: 6),
                                      ],
                                      Expanded(
                                        child: Text(
                                          song.title,
                                          style: AppTypography.songTitle.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    song.artist,
                                    style: AppTypography.artistSubtitle.copyWith(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Play/Pause button
                    IconButton(
                      icon: Icon(
                        widget.playbackState.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.primary,
                        size: 30,
                      ),
                      onPressed: () => widget.controller.togglePlayPause(),
                    ),
                    // Next track button
                    IconButton(
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.textSecondary,
                        size: 26,
                      ),
                      onPressed: _triggerNext,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
