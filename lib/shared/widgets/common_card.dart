import 'package:flutter/material.dart';
import '../../core/theme/wellness_theme_extension.dart';
import '../animations/animation_helpers.dart';

class CommonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final double? borderRadius;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final Border? border;

  const CommonCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.shadows,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wellnessExt = theme.extension<WellnessThemeExtension>();
    final radius = borderRadius ?? wellnessExt?.cardRadius ?? 24.0;
    final cardShadows = shadows ?? wellnessExt?.softShadows ?? [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      )
    ];

    Widget current = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color ?? theme.colorScheme.surface,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: cardShadows,
      ),
      child: child,
    );

    if (onTap != null) {
      current = AnimatedPressable(
        onTap: onTap,
        child: InkWell(
          onTap: null, // AnimatedPressable handles gesture execution
          borderRadius: BorderRadius.circular(radius),
          child: current,
        ),
      );
    }

    return current;
  }
}
