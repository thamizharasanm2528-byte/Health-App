import 'package:flutter/material.dart';

import '../onboarding_page_data.dart';

/// A single onboarding page with an animated illustration,
/// bold title, and description text.
///
/// Designed to be used inside a [PageView]. Content fades and
/// slides in when the page becomes visible.
class OnboardingPageWidget extends StatelessWidget {
  /// Data model holding icon, colour, title, and description.
  final OnboardingPageData data;

  const OnboardingPageWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // ── Illustration container ──
          _IllustrationCircle(
            icon: data.icon,
            color: data.color,
            isDark: isDark,
          ),

          const Spacer(),

          // ── Title ──
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          // ── Description ──
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

/// Large circular container with a floating icon.
///
/// Features a subtle gradient background and decorative
/// concentric rings for visual depth.
class _IllustrationCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;

  const _IllustrationCircle({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Outer decorative ring ──
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                width: 1.5,
              ),
            ),
          ),

          // ── Middle decorative ring ──
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.2 : 0.15),
                width: 1.5,
              ),
            ),
          ),

          // ── Inner gradient circle ──
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: isDark ? 0.25 : 0.15),
                  color.withValues(alpha: isDark ? 0.12 : 0.06),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 64,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
