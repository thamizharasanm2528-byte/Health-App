import 'package:flutter/material.dart';

/// Horizontal scrollable row of quick-action buttons.
///
/// Each button has an icon, label, and colour accent.
/// Tapping triggers navigation to the relevant feature screen.
class QuickActionsBar extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsBar({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: actions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _QuickActionChip(action: actions[index]);
        },
      ),
    );
  }
}

/// Data model for a single quick action.
class QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

class _QuickActionChip extends StatelessWidget {
  final QuickAction action;
  const _QuickActionChip({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 76,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  action.icon,
                  size: 22,
                  color: action.color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                action.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
