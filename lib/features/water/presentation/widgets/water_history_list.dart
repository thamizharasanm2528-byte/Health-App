import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/water_entry.dart';

/// Today's water intake history list with edit and delete actions.
class WaterHistoryList extends StatelessWidget {
  final List<WaterEntry> entries;
  final ValueChanged<WaterEntry> onEdit;
  final ValueChanged<String> onDelete;

  const WaterHistoryList({
    super.key,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'No entries yet today',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Today\'s History',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${entries.length} entries',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...entries.map((entry) => _EntryTile(
              entry: entry,
              onEdit: () => _showEditDialog(context, entry),
              onDelete: () => onDelete(entry.id),
            )),
      ],
    );
  }

  Future<void> _showEditDialog(BuildContext context, WaterEntry entry) async {
    final controller = TextEditingController(text: entry.amountMl.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Amount in ml',
            suffixText: 'ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) Navigator.pop(ctx, val);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      entry.amountMl = result;
      onEdit(entry);
    }
  }
}

class _EntryTile extends StatelessWidget {
  final WaterEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EntryTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = DateFormat.jm().format(entry.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.water_drop_rounded,
              size: 18,
              color: AppColors.water,
            ),
            const SizedBox(width: 10),
            Text(
              '${entry.amountMl} ml',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 18),
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
