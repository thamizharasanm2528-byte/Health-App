import 'package:flutter/material.dart';
import '../../core/constants/app_values.dart';
import 'health_button.dart';

/// Standardized empty-state widget featuring custom vector placeholders,
/// structured titles, friendly taglines, and call-to-action buttons.
class HealthEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Color? color;

  const HealthEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = color ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl, vertical: AppSpacing.x4l),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Programmatic Illustration
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  icon,
                  size: 40,
                  color: accentColor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: 180,
                child: HealthButton(
                  label: actionLabel!,
                  onPressed: onActionPressed!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
