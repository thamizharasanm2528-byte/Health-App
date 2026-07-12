import 'package:flutter/material.dart';
import '../../core/constants/app_values.dart';
import 'health_card.dart';

/// Reusable metric card with state indicators, dynamic feature styling,
/// circular completion rings, and title/subtitle values.
class HealthStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final double? progress; // 0.0 to 1.0
  final VoidCallback? onTap;

  const HealthStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return HealthCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: isDark ? theme.colorScheme.surface : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (progress != null) ...[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: progress!.clamp(0.0, 1.0),
                    strokeWidth: 3,
                    backgroundColor: color.withValues(alpha: 0.15),
                    color: color,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
