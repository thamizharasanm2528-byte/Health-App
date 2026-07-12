import 'package:flutter/material.dart';
import '../../core/constants/app_values.dart';
import '../../core/theme/wellness_theme_extension.dart';
import '../animations/animation_helpers.dart';

/// Reusable premium card container that adapts to Light/Dark themes,
/// supports gradients, borders, and tactile scale press feedback.
class HealthCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? shadows;
  final bool animateOnPress;

  const HealthCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.border,
    this.shadows,
    this.animateOnPress = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<WellnessThemeExtension>();
    
    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: color ?? (gradient == null ? theme.cardTheme.color : null),
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.large),
        border: border ?? Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: shadows ?? ext?.softShadows,
      ),
      child: child,
    );

    if (onTap != null) {
      if (animateOnPress) {
        return AnimatedPressable(
          onTap: onTap,
          child: card,
        );
      } else {
        return InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.large),
          child: card,
        );
      }
    }

    return card;
  }
}
