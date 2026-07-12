import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/circular_progress.dart';
import '../../../../shared/animations/animation_helpers.dart';

class StepProgressCard extends StatelessWidget {
  final int steps;
  final int goal;
  final double progress;
  final int progressPercent;
  final bool isGoalAchieved;
  final bool isSynced;

  const StepProgressCard({
    super.key,
    required this.steps,
    required this.goal,
    required this.progress,
    required this.progressPercent,
    required this.isGoalAchieved,
    this.isSynced = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Estimates
    final distanceKm = steps * 0.00076; // Average 0.76m step length
    final caloriesKcal = steps * 0.042; // Average 0.042 kcal per step
    final activeMinutes = (steps * 0.008).round(); // Average 0.008 minutes per step

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.steps,
            AppColors.steps.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.steps.withValues(alpha: isDark ? 0.15 : 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Synced Badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSynced ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  isSynced ? 'Health Connect Synced' : 'Device Baseline Only',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // ── Step progress count-up ──
          CircularProgress(
            progress: progress.clamp(0.0, 1.0),
            size: 160,
            strokeWidth: 12,
            gradientColors: const [
              Colors.white,
              Color(0x88FFFFFF),
            ],
            trackColor: Colors.white.withValues(alpha: 0.15),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: steps.toDouble()),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_walk_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      val.round().toString(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '/ $goal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ── Secondary metrics row ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FadeInWidget(
                  delay: Duration.zero,
                  child: _MiniStat(
                    icon: Icons.map_outlined,
                    value: '${distanceKm.toStringAsFixed(2)} km',
                    label: 'Distance',
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.15)),
                FadeInWidget(
                  delay: const Duration(milliseconds: 80),
                  child: _MiniStat(
                    icon: Icons.local_fire_department_outlined,
                    value: '${caloriesKcal.round()} kcal',
                    label: 'Calories',
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.15)),
                FadeInWidget(
                  delay: const Duration(milliseconds: 160),
                  child: _MiniStat(
                    icon: Icons.timer_outlined,
                    value: '$activeMinutes min',
                    label: 'Active',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
