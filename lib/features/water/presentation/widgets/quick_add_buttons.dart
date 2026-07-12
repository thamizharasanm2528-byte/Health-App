import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Horizontal row of quick-add water buttons.
///
/// Preset options: 250ml, 500ml, 750ml, and a "Custom" button
/// that opens a dialog for a free-form amount.
class QuickAddButtons extends StatelessWidget {
  final ValueChanged<int> onAdd;

  const QuickAddButtons({super.key, required this.onAdd});

  static const _presets = [250, 500, 750];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Quick Add',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            ..._presets.map((ml) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _QuickButton(
                      label: '${ml}ml',
                      onTap: () => onAdd(ml),
                    ),
                  ),
                )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _QuickButton(
                  label: 'Custom',
                  icon: Icons.edit_rounded,
                  onTap: () => _showCustomDialog(context),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showCustomDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Custom Amount'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter amount in ml',
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
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (result != null) onAdd(result);
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _QuickButton({
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.water.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.water.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.water),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.water,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
