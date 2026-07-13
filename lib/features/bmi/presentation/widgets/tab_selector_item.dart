import 'package:flutter/material.dart';

class TabSelectorItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TabSelectorItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
