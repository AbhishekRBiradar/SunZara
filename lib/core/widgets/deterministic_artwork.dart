import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Generates a deterministic geometric cover for songs or albums without embedded artwork.
/// Seeded by track title / artist so the same track always displays the identical cover,
/// while providing rich variety across different songs.
class DeterministicArtwork extends StatelessWidget {
  final String seed;
  final double size;
  final BorderRadius? borderRadius;

  const DeterministicArtwork({
    super.key,
    required this.seed,
    this.size = 56,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size > 80 ? 16 : 8);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        color: AppColors.surfaceElevated,
        child: CustomPaint(
          size: Size(size, size),
          painter: _DeterministicArtworkPainter(seed: seed),
        ),
      ),
    );
  }
}

class _DeterministicArtworkPainter extends CustomPainter {
  final String seed;

  _DeterministicArtworkPainter({required this.seed});

  int _hashSeed(String s) {
    var hash = 5381;
    for (var i = 0; i < s.length; i++) {
      hash = ((hash << 5) + hash) + s.codeUnitAt(i);
      hash &= 0x7FFFFFFF;
    }
    return hash;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final hash = _hashSeed(seed.isEmpty ? 'SunZara' : seed);
    final random = math.Random(hash);

    // 3 Unique Architectural Styles
    final style = hash % 3;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    // Palette accents for deterministic variety
    final accentVariants = [
      AppColors.primary,
      Color(0xFF00C4D4),
      Color(0xFF28B799),
      Color(0xFF539097),
      Color(0xFFE8E4D3),
    ];
    final accentColor = accentVariants[random.nextInt(accentVariants.length)];

    // Deep Charcoal Base Gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.surfaceHighlight,
          AppColors.surface,
          AppColors.background,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (style == 0) {
      // Style 0: Vinyl concentric grooves with subtle light refraction
      final groovePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.75, size.width * 0.012);

      final numRings = (size.width > 80) ? 7 : 4;
      for (var i = 1; i <= numRings; i++) {
        final r = maxRadius * (0.32 + (0.62 * i / numRings));
        final isAccent = (i == 2 || i == 5);
        groovePaint.color = isAccent
            ? accentColor.withAlpha(80)
            : AppColors.divider.withAlpha(120);
        canvas.drawCircle(center, r, groovePaint);
      }

      // Center vinyl spindle and label
      final centerLabelRadius = maxRadius * 0.28;
      final labelPaint = Paint()
        ..color = accentColor.withAlpha(220)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, centerLabelRadius, labelPaint);

      // Inner ring
      final innerRing = Paint()
        ..color = AppColors.background
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, centerLabelRadius * 0.6, innerRing);

      final centerSpindlePaint = Paint()
        ..color = AppColors.background
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, centerLabelRadius * 0.22, centerSpindlePaint);
    } else if (style == 1) {
      // Style 1: Radial Acoustic Spectrum / Starburst
      final numSpikes = (size.width > 80) ? 24 : 16;
      final spikePaint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(1.5, size.width * 0.02);

      for (var i = 0; i < numSpikes; i++) {
        final angle = (i * 2 * math.pi) / numSpikes;
        final lengthFactor = 0.35 + (0.55 * ((hash + i * 37) % 100) / 100.0);
        final rInner = maxRadius * 0.22;
        final rOuter = maxRadius * lengthFactor;

        final start = Offset(
          center.dx + rInner * math.cos(angle),
          center.dy + rInner * math.sin(angle),
        );
        final end = Offset(
          center.dx + rOuter * math.cos(angle),
          center.dy + rOuter * math.sin(angle),
        );

        final isAccent = (i % 3 == 0);
        spikePaint.color = isAccent ? accentColor : AppColors.textMuted.withAlpha(140);
        canvas.drawLine(start, end, spikePaint);
      }

      // Central core
      final corePaint = Paint()
        ..color = AppColors.surfaceElevated
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, maxRadius * 0.2, corePaint);

      final dotPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, maxRadius * 0.08, dotPaint);
    } else {
      // Style 2: Modern Layered Sine Audio Waves
      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final waveCount = 5;
      for (var w = 0; w < waveCount; w++) {
        final path = Path();
        final yBase = size.height * (0.3 + 0.1 * w);
        final freq = 0.02 + 0.01 * (w % 3);
        final amp = size.height * (0.05 + 0.03 * ((w + 1) % 3));

        path.moveTo(0, yBase);
        for (var x = 0.0; x <= size.width; x += 3) {
          final y = yBase + math.sin(x * freq + (w * 1.2)) * amp;
          path.lineTo(x, y);
        }

        wavePaint.color = (w == 2)
            ? accentColor
            : AppColors.stoneGrey.withAlpha(60 + (w * 25));
        wavePaint.strokeWidth = (w == 2) ? 2.5 : 1.2;
        canvas.drawPath(path, wavePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DeterministicArtworkPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}
