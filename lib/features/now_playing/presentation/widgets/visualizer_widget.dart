import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum VisualizerMode {
  bars,
  circular,
  waveform,
  minimal,
}

class VisualizerWidget extends StatefulWidget {
  final VisualizerMode mode;
  final bool isPlaying;
  final double height;
  final Color? primaryColor;
  final Color? secondaryColor;

  const VisualizerWidget({
    super.key,
    this.mode = VisualizerMode.bars,
    this.isPlaying = true,
    this.height = 120,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<VisualizerWidget> createState() => _VisualizerWidgetState();
}

class _VisualizerWidgetState extends State<VisualizerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isPlaying) {
      _ticker.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _ticker.repeat();
      } else {
        _ticker.stop();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _ticker,
        builder: (context, child) {
          return CustomPaint(
            painter: _VisualizerPainter(
              mode: widget.mode,
              phase: _ticker.value * 2 * math.pi,
              isPlaying: widget.isPlaying,
              primaryColor: (widget.primaryColor ?? AppColors.primary),
              secondaryColor: widget.secondaryColor ?? AppColors.textPrimary,
            ),
          );
        },
      ),
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  final VisualizerMode mode;
  final double phase;
  final bool isPlaying;
  final Color primaryColor;
  final Color secondaryColor;

  _VisualizerPainter({
    required this.mode,
    required this.phase,
    required this.isPlaying,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (mode) {
      case VisualizerMode.bars:
        _paintBars(canvas, size);
        break;
      case VisualizerMode.circular:
        _paintCircular(canvas, size);
        break;
      case VisualizerMode.waveform:
        _paintWaveform(canvas, size);
        break;
      case VisualizerMode.minimal:
        _paintMinimal(canvas, size);
        break;
    }
  }

  void _paintBars(Canvas canvas, Size size) {
    const numBars = 28;
    final barWidth = (size.width / (numBars * 1.6)).clamp(3.0, 10.0);
    final gap = (size.width - (numBars * barWidth)) / (numBars - 1);

    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var i = 0; i < numBars; i++) {
      final x = i * (barWidth + gap) + barWidth / 2;
      final wave = isPlaying
          ? (math.sin(phase + (i * 0.4)) * 0.4 +
              math.cos(phase * 1.5 + (i * 0.2)) * 0.3 +
              0.5)
          : 0.15;
      final barHeight = (size.height * 0.85 * wave).clamp(4.0, size.height);

      final isAccent = (i % 4 == 0);
      paint.color = isAccent ? primaryColor : primaryColor.withAlpha(180);
      paint.strokeWidth = barWidth;

      canvas.drawLine(
        Offset(x, size.height - barHeight),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _paintCircular(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) * 0.28;
    const numPoints = 36;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < numPoints; i++) {
      final angle = (2 * math.pi / numPoints) * i;
      final wave = isPlaying
          ? (math.sin(phase + i * 0.5) * 0.35 + 0.5)
          : 0.1;
      final barLen = baseRadius * 0.7 * wave;

      final p1 = Offset(
        center.dx + baseRadius * math.cos(angle),
        center.dy + baseRadius * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (baseRadius + barLen) * math.cos(angle),
        center.dy + (baseRadius + barLen) * math.sin(angle),
      );

      paint.color = (i % 2 == 0) ? primaryColor : secondaryColor.withAlpha(160);
      canvas.drawLine(p1, p2, paint);
    }

    // Inner ring
    final ringPaint = Paint()
      ..color = primaryColor.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, baseRadius, ringPaint);
  }

  void _paintWaveform(Canvas canvas, Size size) {
    final path = Path();
    final midY = size.height / 2;
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    path.moveTo(0, midY);
    for (var x = 0.0; x <= size.width; x += 4) {
      final normX = x / size.width;
      final amp = isPlaying
          ? math.sin(normX * math.pi) *
              (math.sin(normX * 8 + phase) * 0.6 +
                  math.cos(normX * 16 - phase * 1.5) * 0.4) *
              (size.height * 0.4)
          : 0.0;
      path.lineTo(x, midY + amp);
    }

    canvas.drawPath(path, paint);
  }

  void _paintMinimal(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final barWidth = isPlaying
        ? (size.width * (0.4 + 0.4 * (math.sin(phase) * 0.5 + 0.5)))
        : size.width * 0.2;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final startX = (size.width - barWidth) / 2;
    canvas.drawLine(Offset(startX, midY), Offset(startX + barWidth, midY), paint);
  }

  @override
  bool shouldRepaint(covariant _VisualizerPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.mode != mode;
  }
}
