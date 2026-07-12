import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Full-screen gradient background for the splash screen.
///
/// Uses the brand primary colour as the dominant tone with a
/// radial gradient overlay for depth. Adapts to dark mode by
/// shifting to the dark surface palette.
class SplashBackground extends StatelessWidget {
  /// Child widget rendered on top of the gradient.
  final Widget child;

  const SplashBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dominant colour shifts per theme.
    final baseColor =
        isDark ? const Color(0xFF0A1F12) : AppColors.primary;
    final accentColor =
        isDark ? const Color(0xFF163D25) : const Color(0xFF3DA06A);
    final highlightColor =
        isDark ? const Color(0xFF1E5435) : const Color(0xFF5CC88A);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor, accentColor],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.3),
            radius: 1.2,
            colors: [
              highlightColor.withValues(alpha: 0.25),
              Colors.transparent,
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
