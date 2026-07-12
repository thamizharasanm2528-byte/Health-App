import 'package:flutter/material.dart';

/// Food reminder card and next-reminder card for the dashboard.
///
/// Displays an actionable reminder (e.g. "Time to eat 10 almonds")
/// with a "Mark as Completed" button, or a next-scheduled
/// reminder with time.
class ReminderCard extends StatelessWidget {
  final String emoji;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? trailingText;

  const ReminderCard({
    super.key,
    required this.emoji,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // ── Emoji ──
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),

          // ── Content ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: FilledButton.tonal(
                      onPressed: onAction,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        textStyle: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(actionLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Trailing (time label) ──
          if (trailingText != null)
            Text(
              trailingText!,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
        ],
      ),
    );
  }
}
