import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/common_card.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../alarm/presentation/alarm_provider.dart';
import '../../../reminders/presentation/reminders_provider.dart';
import '../../data/upcoming_reminder_info.dart';
import '../dashboard_provider.dart';

class UpcomingReminderCard extends StatelessWidget {
  const UpcomingReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<AlarmProvider, RemindersProvider>(
      builder: (context, alarmProv, remindersProv, child) {
        final nearest = _getNearestReminder(context, alarmProv, remindersProv);
        if (nearest == null) {
          return CommonCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Text('🔔', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No upcoming reminders scheduled today.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, RouteNames.settings),
                  child: const Text('Manage'),
                ),
              ],
            ),
          );
        }

        return CommonCard(
          padding: const EdgeInsets.all(16),
          onTap: nearest.onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(nearest.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nearest.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nearest.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: StatusChip(
                            key: ValueKey<String>(nearest.countdownText),
                            label: nearest.countdownText,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static UpcomingReminderInfo? _getNearestReminder(
    BuildContext context,
    AlarmProvider alarmProv,
    RemindersProvider remindersProv,
  ) {
    final now = DateTime.now();
    final list = <UpcomingReminderInfo>[];

    // 1. Wake-up Alarm
    final alarmSettings = alarmProv.alarmSettings;
    if (alarmSettings != null && alarmSettings.isEnabled) {
      final hour = alarmSettings.hour;
      final minute = alarmSettings.minute;
      DateTime nextAlarm;
      if (alarmSettings.repeatDays.isEmpty) {
        nextAlarm = DateTime(now.year, now.month, now.day, hour, minute);
        if (nextAlarm.isBefore(now)) {
          nextAlarm = nextAlarm.add(const Duration(days: 1));
        }
      } else {
        DateTime? earliest;
        for (final day in alarmSettings.repeatDays) {
          var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
          var daysOffset = day - now.weekday;
          if (daysOffset < 0 || (daysOffset == 0 && scheduled.isBefore(now))) {
            daysOffset += 7;
          }
          final target = scheduled.add(Duration(days: daysOffset));
          if (earliest == null || target.isBefore(earliest)) {
            earliest = target;
          }
        }
        nextAlarm = earliest ?? now;
      }

      final diff = nextAlarm.difference(now);
      final countdown = _formatCountdown(diff);
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayH = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final timeStr = '${displayH.toString()}:${minute.toString().padLeft(2, '0')} $period';
      final desc = nextAlarm.day == now.day ? 'Today at $timeStr' : 'Tomorrow at $timeStr';

      list.add(UpcomingReminderInfo(
        title: 'Wake-up Alarm',
        description: desc,
        countdownText: countdown,
        emoji: '⏰',
        nextTrigger: nextAlarm,
        onTap: () => Navigator.pushNamed(context, RouteNames.alarm),
      ));
    }

    for (final reminder in remindersProv.reminders) {
      if (!reminder.isEnabled || reminder.type == 'food') continue;
      final nextOcc = remindersProv.getNextOccurrence(reminder);
      if (nextOcc == null) continue;

      final diff = nextOcc.difference(now);
      final countdown = _formatCountdown(diff);

      if (reminder.reminderTimes.isEmpty) continue;
      final hour = nextOcc.hour;
      final minute = nextOcc.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayH = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final timeStr = '${displayH.toString()}:${minute.toString().padLeft(2, '0')} $period';
      
      String prefix = 'Reminder';
      if (reminder.type == 'water') {
        prefix = 'Water';
      } else if (reminder.type == 'bedtime') {
        prefix = 'Sleep';
      }
      
      final desc = '$prefix at $timeStr';

      String emoji = '🔔';
      VoidCallback onTap = () {};
      if (reminder.type == 'water') {
        emoji = '💧';
        onTap = () => context.read<DashboardProvider>().setTabIndex(1);
      } else if (reminder.type == 'bedtime') {
        emoji = '🛌';
        onTap = () => context.read<DashboardProvider>().setTabIndex(4);
      }

      list.add(UpcomingReminderInfo(
        title: reminder.title,
        description: desc,
        countdownText: countdown,
        emoji: emoji,
        nextTrigger: nextOcc,
        onTap: onTap,
      ));
    }

    if (list.isEmpty) return null;

    list.sort((a, b) => a.nextTrigger.compareTo(b.nextTrigger));
    return list.first;
  }

  static String _formatCountdown(Duration diff) {
    final minutes = diff.inMinutes;
    if (minutes < 60) {
      return 'in $minutes min';
    }
    final hours = diff.inHours;
    final remainingMinutes = minutes % 60;
    if (hours < 24) {
      return remainingMinutes > 0 ? 'in $hours hr $remainingMinutes min' : 'in $hours hr';
    }
    final days = diff.inDays;
    return 'in $days days';
  }
}
