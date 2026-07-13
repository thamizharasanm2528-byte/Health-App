import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/animations/animation_helpers.dart';
import '../../data/bmi_entry.dart';

class BmiHistorySection extends StatelessWidget {
  final List<BMIEntry> history;
  final ValueChanged<String> onDelete;

  const BmiHistorySection({
    super.key,
    required this.history,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calculation History',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = history[index];
            final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(entry.timestamp);
            final delayMs = (index * 50).clamp(0, 300);

            return FadeInWidget(
              delay: Duration(milliseconds: delayMs),
              child: Dismissible(
                key: ValueKey(entry.id),
                direction: DismissDirection.endToStart,
                // Perform deletion inside confirmDismiss and return false.
                // Returning false prevents the Dismissible from entering the
                // "dismissed" state. The provider's notifyListeners() call
                // rebuilds the list without this entry, removing it from the
                // widget tree cleanly — no "dismissed widget still in tree" error.
                confirmDismiss: (direction) async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete BMI Record'),
                      content: const Text(
                        'Are you sure you want to permanently delete this BMI history log?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(
                            'Delete',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    onDelete(entry.id);
                    if (context.mounted) {
                      HealthSnackBar.showSuccess(
                        context,
                        'BMI entry deleted successfully! 🗑️',
                      );
                    }
                  }
                  // Always return false — the item is removed by provider rebuild,
                  // not by the Dismissible's own dismiss lifecycle.
                  return false;
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMI: ${entry.bmiValue.toStringAsFixed(1)} (${entry.category})',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Weight: ${entry.weightKg.toStringAsFixed(1)} kg | Height: ${entry.heightCm.toStringAsFixed(0)} cm',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        color: theme.colorScheme.error,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete BMI Record'),
                              content: const Text(
                                'Are you sure you want to permanently delete this BMI history log?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: theme.colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            onDelete(entry.id);
                            if (context.mounted) {
                              HealthSnackBar.showSuccess(
                                context,
                                'BMI entry deleted successfully! 🗑️',
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
