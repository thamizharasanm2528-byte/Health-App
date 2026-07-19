import 'package:flutter/material.dart';
import '../../../../core/services/notifications/notification_service.dart';
import '../../../../core/services/notifications/notification_permission_service.dart';
import '../../../reminders/presentation/reminders_provider.dart';
import '../../../reminders/data/reminder_model.dart';
import 'time_picker_row.dart';
import 'days_selector.dart';
import 'toggle_row.dart';
import 'preview_and_test_row.dart';

class WaterReminderCard extends StatelessWidget {
  final RemindersProvider remindersProv;
  final Function(ReminderModel) onTestReminder;

  const WaterReminderCard({
    super.key,
    required this.remindersProv,
    required this.onTestReminder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminder = remindersProv.getReminderById(
      'water',
      type: 'water',
      title: '💧 Time to Drink Water!',
      body: 'Stay hydrated — your body will thank you.',
      defaultTimes: [480], // default 8:00 AM
    );

    final bool isInterval = reminder.reminderTimes.length > 1;

    // Default values if empty or once-daily
    int intervalMinutes = 60;
    int startHour = 8;
    int startMinute = 0;
    int endHour = 20;
    int endMinute = 0;

    if (isInterval) {
      startHour = reminder.reminderTimes.first ~/ 60;
      startMinute = reminder.reminderTimes.first % 60;
      endHour = reminder.reminderTimes.last ~/ 60;
      endMinute = reminder.reminderTimes.last % 60;
      intervalMinutes = reminder.reminderTimes[1] - reminder.reminderTimes[0];
      if (intervalMinutes != 30 && intervalMinutes != 60 && intervalMinutes != 120) {
        intervalMinutes = 60; // fallback default
      }
    } else if (reminder.reminderTimes.isNotEmpty) {
      startHour = reminder.reminderTimes.first ~/ 60;
      startMinute = reminder.reminderTimes.first % 60;
    }

    final currentTypeVal = isInterval ? intervalMinutes : 0;

    List<int> calculateTimes(int typeVal, int startH, int startM, int endH, int endM) {
      if (typeVal == 0) {
        return [startH * 60 + startM];
      }
      final startTotal = startH * 60 + startM;
      var endTotal = endH * 60 + endM;
      if (endTotal <= startTotal) {
        endTotal = startTotal + 120; // fallback
      }
      final times = <int>[];
      for (var t = startTotal; t <= endTotal; t += typeVal) {
        times.add(t);
      }
      return times;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('💧', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'Water Reminder',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: reminder.isEnabled,
                  onChanged: (val) {
                    reminder.isEnabled = val;
                    remindersProv.saveReminder(reminder);
                  },
                ),
              ],
            ),
            const Divider(height: 24),

            // Dropdown to choose Reminder Frequency (Specific Time vs Interval)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Frequency',
                  style: theme.textTheme.bodyMedium,
                ),
                DropdownButton<int>(
                  value: currentTypeVal,
                  underline: const SizedBox(),
                  alignment: Alignment.centerRight,
                  borderRadius: BorderRadius.circular(12),
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Once Daily (Specific Time)'),
                    ),
                    DropdownMenuItem(
                      value: 30,
                      child: Text('Every 30 Minutes'),
                    ),
                    DropdownMenuItem(
                      value: 60,
                      child: Text('Every 1 Hour'),
                    ),
                    DropdownMenuItem(
                      value: 120,
                      child: Text('Every 2 Hours'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      reminder.reminderTimes = calculateTimes(val, startHour, startMinute, endHour, endMinute);
                      remindersProv.saveReminder(reminder);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (currentTypeVal == 0)
              TimePickerRow(
                time: TimeOfDay(hour: startHour, minute: startMinute),
                label: 'Reminder Time',
                onTimeSelected: (newTime) {
                  reminder.reminderTimes = calculateTimes(0, newTime.hour, newTime.minute, endHour, endMinute);
                  remindersProv.saveReminder(reminder);
                },
              )
            else ...[
              TimePickerRow(
                time: TimeOfDay(hour: startHour, minute: startMinute),
                label: 'Start Time',
                onTimeSelected: (newTime) {
                  reminder.reminderTimes = calculateTimes(currentTypeVal, newTime.hour, newTime.minute, endHour, endMinute);
                  remindersProv.saveReminder(reminder);
                },
              ),
              const SizedBox(height: 12),
              TimePickerRow(
                time: TimeOfDay(hour: endHour, minute: endMinute),
                label: 'End Time',
                onTimeSelected: (newTime) {
                  reminder.reminderTimes = calculateTimes(currentTypeVal, startHour, startMinute, newTime.hour, newTime.minute);
                  remindersProv.saveReminder(reminder);
                },
              ),
            ],
            const SizedBox(height: 14),

            DaysSelector(
              selectedDays: reminder.repeatDays,
              onDayToggled: (day) {
                final days = List<int>.from(reminder.repeatDays);
                if (days.contains(day)) {
                  days.remove(day);
                } else {
                  days.add(day);
                }
                reminder.repeatDays = days;
                remindersProv.saveReminder(reminder);
              },
            ),
            const SizedBox(height: 14),
            ToggleRow(
              icon: Icons.vibration_rounded,
              title: 'Vibration',
              value: reminder.vibrate,
              onChanged: (val) {
                reminder.vibrate = val;
                remindersProv.saveReminder(reminder);
              },
            ),
            ToggleRow(
              icon: Icons.volume_up_rounded,
              title: 'System Sound',
              value: reminder.sound,
              onChanged: (val) {
                reminder.sound = val;
                remindersProv.saveReminder(reminder);
              },
            ),
            const SizedBox(height: 12),
            PreviewAndTestRow(
              previewText: 'Next Trigger: ${remindersProv.getNextReminderText('water')}',
              onTestTap: () => onTestReminder(reminder),
            ),
          ],
        ),
      ),
    );
  }
}
