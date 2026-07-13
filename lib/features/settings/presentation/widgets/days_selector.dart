import 'package:flutter/material.dart';

class DaysSelector extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<int> onDayToggled;

  const DaysSelector({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
  });

  static const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat Days (Empty = Daily)',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: List.generate(7, (index) {
            final dayIndex = index + 1;
            final isSelected = selectedDays.contains(dayIndex);
            return ChoiceChip(
              label: Text(_weekdayNames[index]),
              selected: isSelected,
              onSelected: (_) => onDayToggled(dayIndex),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            );
          }),
        ),
      ],
    );
  }
}
