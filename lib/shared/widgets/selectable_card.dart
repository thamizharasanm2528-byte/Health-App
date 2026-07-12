import 'package:flutter/material.dart';

/// Tappable card with a visually distinct selected state.
///
/// Shows a primary-coloured border and subtle background tint
/// when [isSelected] is `true`. Ideal for single-choice options
/// like activity level selection.
class SelectableCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets padding;

  const SelectableCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? primary.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? primary : theme.colorScheme.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
