import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clean, high-resolution SunZara Brand Logo Widget
/// Renders the generated SunZara crest with glowing acoustic accents
class SunZaraLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final VoidCallback? onTap;

  const SunZaraLogo({
    super.key,
    this.size = 36,
    this.showGlow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: size * 0.35,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          'assets/images/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Elegant vector fallback
            return Container(
              color: AppColors.surfaceElevated,
              alignment: Alignment.center,
              child: Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.primary,
                size: size * 0.6,
              ),
            );
          },
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: image);
    }
    return image;
  }
}
