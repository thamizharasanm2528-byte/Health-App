import 'package:flutter/material.dart';

/// Animated title and tagline group for the splash screen.
///
/// Each text element fades in and slides upward on its own
/// staggered timeline, creating a cascading reveal effect.
class SplashTextGroup extends StatelessWidget {
  /// Title fade opacity (0 → 1).
  final Animation<double> titleFade;

  /// Title vertical offset (20 → 0).
  final Animation<double> titleSlide;

  /// Tagline fade opacity (0 → 1).
  final Animation<double> taglineFade;

  /// Tagline vertical offset (20 → 0).
  final Animation<double> taglineSlide;

  const SplashTextGroup({
    super.key,
    required this.titleFade,
    required this.titleSlide,
    required this.taglineFade,
    required this.taglineSlide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── App Title ──
        AnimatedBuilder(
          animation: Listenable.merge([titleFade, titleSlide]),
          builder: (context, child) {
            return Opacity(
              opacity: titleFade.value,
              child: Transform.translate(
                offset: Offset(0, titleSlide.value),
                child: child,
              ),
            );
          },
          child: const Text(
            'Health Companion',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Tagline ──
        AnimatedBuilder(
          animation: Listenable.merge([taglineFade, taglineSlide]),
          builder: (context, child) {
            return Opacity(
              opacity: taglineFade.value,
              child: Transform.translate(
                offset: Offset(0, taglineSlide.value),
                child: child,
              ),
            );
          },
          child: Text(
            'Build Healthy Habits Every Day',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}
