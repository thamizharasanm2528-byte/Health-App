import 'package:flutter/material.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/animations/animation_helpers.dart';
import '../../../../shared/widgets/circular_progress.dart';

class HealthScoreCard extends StatelessWidget {
  final int scorePercent;
  final String message;

  const HealthScoreCard({
    super.key,
    required this.scorePercent,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primary,
        theme.colorScheme.secondary,
      ],
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteNames.healthScore);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: isDark ? 0.15 : 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircularProgress(
              progress: scorePercent / 100,
              size: 96,
              strokeWidth: 9,
              gradientColors: const [
                Colors.white,
                Color(0x88FFFFFF),
              ],
              trackColor: Colors.white.withValues(alpha: 0.15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedCounter(
                    value: scorePercent,
                    suffix: '%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Health Score',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
