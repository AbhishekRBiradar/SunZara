import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated 3-bar equalizer indicator displayed beside the song title
/// when a track is actively playing.
class PlayingEqualizerBars extends StatefulWidget {
  final bool isPlaying;
  final double size;
  final Color? color;

  const PlayingEqualizerBars({
    super.key,
    this.isPlaying = true,
    this.size = 14,
    this.color,
  });

  @override
  State<PlayingEqualizerBars> createState() => _PlayingEqualizerBarsState();
}

class _PlayingEqualizerBarsState extends State<PlayingEqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PlayingEqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        // 3 bars with staggered phase
        final h1 = 0.35 + (0.65 * (widget.isPlaying ? (val) : 0.4));
        final h2 = 0.30 + (0.70 * (widget.isPlaying ? (1.0 - val) : 0.7));
        final h3 = 0.40 + (0.60 * (widget.isPlaying ? ((val + 0.5) % 1.0) : 0.3));

        return SizedBox(
          width: widget.size * 1.1,
          height: widget.size,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(h1),
              _buildBar(h2),
              _buildBar(h3),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(double heightFraction) {
    final barWidth = widget.size * 0.22;
    return Container(
      width: barWidth,
      height: widget.size * heightFraction,
      decoration: BoxDecoration(
        color: widget.color ?? AppColors.primary,
        borderRadius: BorderRadius.circular(barWidth / 2),
      ),
    );
  }
}
