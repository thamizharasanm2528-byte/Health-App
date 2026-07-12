import 'package:flutter/material.dart';

/// User initials profile widget featuring gradient backdrops and soft drop shadows.
class HealthAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double fontSize;
  final List<Color>? gradientColors;

  const HealthAvatar({
    super.key,
    required this.name,
    this.size = 80,
    this.fontSize = 28,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    final colors = gradientColors ?? [theme.colorScheme.primary, theme.colorScheme.secondary];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.25),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.06),
          )
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
