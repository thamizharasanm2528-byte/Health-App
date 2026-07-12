import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Card showing current and best consecutive step goal achievement streaks.
class StepStreakCard extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;

  const StepStreakCard({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // ── Flame Emoji ──
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.steps.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('⚡', style: TextStyle(fontSize: 24)),
          ),

          const SizedBox(width: 16),

          // ── Current Streak ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal Achieve Streak',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$currentStreak ${currentStreak == 1 ? 'day' : 'days'}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // ── Best Streak ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Best',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$bestStreak ${bestStreak == 1 ? 'day' : 'days'}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.steps,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
