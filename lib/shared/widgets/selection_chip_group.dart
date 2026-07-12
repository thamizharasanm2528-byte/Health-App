import 'package:flutter/material.dart';

/// A horizontal wrap of selectable chips for option picking.
///
/// Supports both single-select and multi-select modes.
/// Selected chips get the primary colour fill.
class SelectionChipGroup<T> extends StatelessWidget {
  /// All available options.
  final List<T> options;

  /// Currently selected option(s).
  final Set<T> selected;

  /// Label builder for each option.
  final String Function(T) labelBuilder;

  /// Called when an option is toggled.
  final ValueChanged<T> onSelected;

  const SelectionChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(labelBuilder(option)),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          showCheckmark: false,
          selectedColor: theme.colorScheme.primaryContainer,
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
          labelStyle: theme.textTheme.labelLarge?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }
}
