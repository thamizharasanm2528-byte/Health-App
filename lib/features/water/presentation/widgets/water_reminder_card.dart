import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Display-only card for water notification configurations.
///
/// Shows status (ON/OFF) and active reminder settings, with a button to navigate to Settings.
class WaterReminderCard extends StatelessWidget {
  final bool enabled;
  final int intervalMinutes;
  final int startHour;
  final int endHour;
  final VoidCallback onManagePressed;

  const WaterReminderCard({
    super.key,
    required this.enabled,
    required this.intervalMinutes,
    required this.startHour,
    required this.endHour,
    required this.onManagePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with Title and Status ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.water_drop_rounded,
                    size: 22,
                    color: AppColors.water,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Water Reminders',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Status: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    enabled ? '🟢 ON' : '🔴 OFF',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: enabled ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // ── Active Schedule Configuration Info ──
          Row(
            children: [
              Expanded(
                child: _ScheduleInfoItem(
                  icon: Icons.timer_outlined,
                  label: 'Interval',
                  value: _formatInterval(intervalMinutes),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ScheduleInfoItem(
                  icon: Icons.wb_twilight_rounded,
                  label: 'Active Hours',
                  value: '${_formatHour(startHour)} - ${_formatHour(endHour)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Action Button to Edit ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onManagePressed,
              icon: const Icon(Icons.edit_calendar_rounded, size: 16),
              label: const Text('Manage Reminders'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.water,
                side: BorderSide(color: AppColors.water.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }

  String _formatHour(int h) {
    final period = h >= 12 ? 'PM' : 'AM';
    final display = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$display:00 $period';
  }
}

class _ScheduleInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ScheduleInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
