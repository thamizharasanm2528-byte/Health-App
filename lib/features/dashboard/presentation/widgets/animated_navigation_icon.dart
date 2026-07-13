import 'package:flutter/material.dart';

class AnimatedNavigationIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;

  const AnimatedNavigationIcon({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    if (disableAnimations) {
      return Icon(
        isSelected ? selectedIcon : icon,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      );
    }

    return AnimatedScale(
      scale: isSelected ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          isSelected ? selectedIcon : icon,
          key: ValueKey<bool>(isSelected),
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
