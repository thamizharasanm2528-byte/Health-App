import 'package:flutter/material.dart';
import '../../core/constants/app_values.dart';
import '../../core/theme/app_colors.dart';

enum HealthChipStyle {
  success,
  warning,
  error,
  info,
  primary,
  secondary,
}

/// Unified tag chip with color mappings for M3 states or custom properties.
class HealthChip extends StatelessWidget {
  final String label;
  final HealthChipStyle style;
  final Color? customColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const HealthChip({
    super.key,
    required this.label,
    this.style = HealthChipStyle.info,
    this.customColor,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(theme);
    final bgColor = color.withValues(alpha: 0.12);
    
    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.s),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chip,
      );
    }
    return chip;
  }

  Color _getColor(ThemeData theme) {
    if (customColor != null) return customColor!;
    switch (style) {
      case HealthChipStyle.success:
        return AppColors.success;
      case HealthChipStyle.warning:
        return AppColors.warning;
      case HealthChipStyle.error:
        return AppColors.error;
      case HealthChipStyle.primary:
        return theme.colorScheme.primary;
      case HealthChipStyle.secondary:
        return theme.colorScheme.secondary;
      case HealthChipStyle.info:
        return theme.colorScheme.primary;
    }
  }
}
