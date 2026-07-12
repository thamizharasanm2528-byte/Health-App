import 'package:flutter/material.dart';

/// Animated health-themed logo for the splash screen.
///
/// Displays a circular container with a heart-pulse icon
/// that fades in and scales up using the provided animations.
class SplashLogo extends StatelessWidget {
  /// Controls the fade-in opacity (0 → 1).
  final Animation<double> fadeAnimation;

  /// Controls the scale transform (0.6 → 1.0).
  final Animation<double> scaleAnimation;

  const SplashLogo({
    super.key,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([fadeAnimation, scaleAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: _LogoContent(),
    );
  }
}

/// Static logo content — extracted so the child is not rebuilt
/// on every animation tick.
class _LogoContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.monitor_heart_rounded,
          size: 56,
          color: Colors.white,
        ),
      ),
    );
  }
}
