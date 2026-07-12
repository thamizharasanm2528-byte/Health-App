import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../animations/animation_helpers.dart';

enum HealthButtonStyle {
  filled,
  outlined,
  danger,
}

class HealthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final HealthButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;

  const HealthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = HealthButtonStyle.filled,
    this.icon,
    this.isLoading = false,
    this.height = 52.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? getBgColor() {
      if (onPressed == null) return theme.colorScheme.onSurface.withValues(alpha: 0.12);
      switch (style) {
        case HealthButtonStyle.filled:
          return theme.colorScheme.primary;
        case HealthButtonStyle.danger:
          return AppColors.error;
        case HealthButtonStyle.outlined:
          return Colors.transparent;
      }
    }

    Color getFgColor() {
      if (onPressed == null) return theme.colorScheme.onSurface.withValues(alpha: 0.38);
      switch (style) {
        case HealthButtonStyle.filled:
          return theme.colorScheme.onPrimary;
        case HealthButtonStyle.danger:
          return Colors.white;
        case HealthButtonStyle.outlined:
          return theme.colorScheme.primary;
      }
    }

    BorderSide? getBorder() {
      if (style == HealthButtonStyle.outlined) {
        final color = onPressed == null
            ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
            : theme.colorScheme.primary;
        return BorderSide(color: color, width: 1.5);
      }
      return BorderSide.none;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: getBgColor(),
      foregroundColor: getFgColor(),
      disabledBackgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
      disabledForegroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.38),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // matching design system radius
        side: getBorder() ?? BorderSide.none,
      ),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );

    final content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(getFgColor()),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final button = SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: (onPressed == null || isLoading) ? null : () {},
        child: content,
      ),
    );

    if (onPressed == null || isLoading) {
      return button;
    }

    return AnimatedPressable(
      onTap: onPressed,
      child: IgnorePointer(
        child: button,
      ),
    );
  }
}
