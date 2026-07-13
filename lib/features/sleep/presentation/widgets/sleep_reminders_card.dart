import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SleepRemindersCard extends StatelessWidget {
  final bool bedtimeEnabled;
  final bool wakeUpEnabled;
  final VoidCallback onManageBedtime;
  final VoidCallback onManageWakeUp;

  const SleepRemindersCard({
    super.key,
    required this.bedtimeEnabled,
    required this.wakeUpEnabled,
    required this.onManageBedtime,
    required this.onManageWakeUp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
          Text(
            'Reminders & Alerts',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Bedtime Reminder Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bedtime Reminder',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        bedtimeEnabled ? '🟢 ON' : '🔴 OFF',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: bedtimeEnabled ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton.filledTonal(
                onPressed: onManageBedtime,
                icon: const Icon(Icons.settings_outlined, size: 18),
                tooltip: 'Manage Bedtime Reminder',
              ),
            ],
          ),
          const Divider(height: 24),
          // Wake Up Reminder / Alarm Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wake-up Reminder',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        wakeUpEnabled ? '🟢 ON' : '🔴 OFF',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: wakeUpEnabled ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton.filledTonal(
                onPressed: onManageWakeUp,
                icon: const Icon(Icons.alarm_rounded, size: 18),
                tooltip: 'Manage Wake-up Alarm',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
