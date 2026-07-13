import 'package:flutter/material.dart';
import '../../data/alarm_settings_model.dart';
import '../alarm_provider.dart';

class AlarmTile extends StatelessWidget {
  final AlarmSettingsModel alarm;
  final AlarmProvider alarmProv;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const AlarmTile({
    super.key,
    required this.alarm,
    required this.alarmProv,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = alarmProv.formatTimeOfDay(alarm.hour, alarm.minute);
    final repeatDaysStr = alarmProv.formatRepeatDaysList(alarm.repeatDays);

    final daysOfWeek = [
      {'label': 'M', 'day': 1},
      {'label': 'T', 'day': 2},
      {'label': 'W', 'day': 3},
      {'label': 'T', 'day': 4},
      {'label': 'F', 'day': 5},
      {'label': 'S', 'day': 6},
      {'label': 'S', 'day': 7},
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: alarm.isEnabled
              ? theme.colorScheme.primary.withValues(alpha: 0.25)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: alarm.isEnabled ? 1.5 : 1.0,
        ),
      ),
      color: alarm.isEnabled
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.05)
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Time & Switch Row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeStr,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: alarm.isEnabled
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (alarm.label.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          alarm.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Switch.adaptive(
                    value: alarm.isEnabled,
                    onChanged: onToggle,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Days repetition row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: daysOfWeek.map((dayMap) {
                        final label = dayMap['label'] as String;
                        final dayVal = dayMap['day'] as int;
                        final isSelected = alarm.repeatDays.contains(dayVal);

                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            child: Text(
                              label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        alarm.sound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        alarm.vibrate ? Icons.vibration_rounded : Icons.phone_android_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: onDelete,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Repeat: $repeatDaysStr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Snooze: ${alarm.snoozeDurationMinutes}m',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
