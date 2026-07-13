import 'package:flutter/material.dart';
import '../../../reminders/presentation/reminders_provider.dart';
import '../../../reminders/data/reminder_model.dart';
import 'time_picker_row.dart';
import 'days_selector.dart';
import 'toggle_row.dart';
import 'preview_and_test_row.dart';

class BedtimeReminderCard extends StatelessWidget {
  final RemindersProvider remindersProv;
  final Function(ReminderModel) onTestReminder;

  const BedtimeReminderCard({
    super.key,
    required this.remindersProv,
    required this.onTestReminder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminder = remindersProv.getReminderById(
      'bedtime',
      type: 'bedtime',
      title: '🛌 Bedtime is approaching!',
      body: 'Wind down and prepare for a restful sleep.',
      defaultTimes: [1350], // default 10:30 PM
    );

    final timeInMin = reminder.reminderTimes.isNotEmpty ? reminder.reminderTimes.first : 1350;
    final timeOfDay = TimeOfDay(hour: timeInMin ~/ 60, minute: timeInMin % 60);

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
                    const Text('🛌', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'Bedtime Reminder',
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
            TimePickerRow(
              time: timeOfDay,
              onTimeSelected: (newTime) {
                reminder.reminderTimes = [newTime.hour * 60 + newTime.minute];
                remindersProv.saveReminder(reminder);
              },
            ),
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
              previewText: 'Next Trigger: ${remindersProv.getNextReminderText('bedtime')}',
              onTestTap: () => onTestReminder(reminder),
            ),
          ],
        ),
      ),
    );
  }
}
