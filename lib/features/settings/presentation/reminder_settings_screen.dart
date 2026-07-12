import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alarm/alarm.dart';

import '../../reminders/presentation/reminders_provider.dart';
import '../../reminders/data/reminder_model.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final List<String> _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remindersProv = context.watch<RemindersProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Section 2: Water Reminder ──
          _buildWaterReminderCard(context, remindersProv, theme),

          const SizedBox(height: 16),

          // ── Section 3: Bedtime Reminder ──
          _buildBedtimeReminderCard(context, remindersProv, theme),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWaterReminderCard(BuildContext context, RemindersProvider remindersProv, ThemeData theme) {
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
              _buildTimePickerRow(
                context: context,
                theme: theme,
                time: TimeOfDay(hour: startHour, minute: startMinute),
                label: 'Reminder Time',
                onTimeSelected: (newTime) {
                  reminder.reminderTimes = calculateTimes(0, newTime.hour, newTime.minute, endHour, endMinute);
                  remindersProv.saveReminder(reminder);
                },
              )
            else ...[
              _buildTimePickerRow(
                context: context,
                theme: theme,
                time: TimeOfDay(hour: startHour, minute: startMinute),
                label: 'Start Time',
                onTimeSelected: (newTime) {
                  reminder.reminderTimes = calculateTimes(currentTypeVal, newTime.hour, newTime.minute, endHour, endMinute);
                  remindersProv.saveReminder(reminder);
                },
              ),
              const SizedBox(height: 12),
              _buildTimePickerRow(
                context: context,
                theme: theme,
                time: TimeOfDay(hour: endHour, minute: endMinute),
                label: 'End Time',
                onTimeSelected: (newTime) {
                  reminder.reminderTimes = calculateTimes(currentTypeVal, startHour, startMinute, newTime.hour, newTime.minute);
                  remindersProv.saveReminder(reminder);
                },
              ),
            ],
            const SizedBox(height: 14),

            _buildDaysSelector(
              theme: theme,
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
            _buildToggleRow(
              icon: Icons.vibration_rounded,
              title: 'Vibration',
              value: reminder.vibrate,
              onChanged: (val) {
                reminder.vibrate = val;
                remindersProv.saveReminder(reminder);
              },
            ),
            _buildToggleRow(
              icon: Icons.volume_up_rounded,
              title: 'System Sound',
              value: reminder.sound,
              onChanged: (val) {
                reminder.sound = val;
                remindersProv.saveReminder(reminder);
              },
            ),
            const SizedBox(height: 12),
            _buildPreviewAndTestRow(
              theme: theme,
              previewText: 'Next Trigger: ${remindersProv.getNextReminderText('water')}',
              onTestTap: () async {
                await _triggerTestNotification(reminder);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test Water Notification scheduled in 5 seconds...'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBedtimeReminderCard(BuildContext context, RemindersProvider remindersProv, ThemeData theme) {
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
            _buildTimePickerRow(
              context: context,
              theme: theme,
              time: timeOfDay,
              onTimeSelected: (newTime) {
                reminder.reminderTimes = [newTime.hour * 60 + newTime.minute];
                remindersProv.saveReminder(reminder);
              },
            ),
            const SizedBox(height: 14),
            _buildDaysSelector(
              theme: theme,
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
            _buildToggleRow(
              icon: Icons.vibration_rounded,
              title: 'Vibration',
              value: reminder.vibrate,
              onChanged: (val) {
                reminder.vibrate = val;
                remindersProv.saveReminder(reminder);
              },
            ),
            _buildToggleRow(
              icon: Icons.volume_up_rounded,
              title: 'System Sound',
              value: reminder.sound,
              onChanged: (val) {
                reminder.sound = val;
                remindersProv.saveReminder(reminder);
              },
            ),
            const SizedBox(height: 12),
            _buildPreviewAndTestRow(
              theme: theme,
              previewText: 'Next Trigger: ${remindersProv.getNextReminderText('bedtime')}',
              onTestTap: () async {
                await _triggerTestNotification(reminder);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test Bedtime Notification scheduled in 5 seconds...'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }



  // ═══════════════════════════════════════════════════════════════════════════
  // Card Sub-components Builders
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTimePickerRow({
    required BuildContext context,
    required ThemeData theme,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onTimeSelected,
    String label = 'Time',
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.access_time_rounded, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: time);
            if (picked != null) {
              onTimeSelected(picked);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatTimeStr(time),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaysSelector({
    required ThemeData theme,
    required List<int> selectedDays,
    required ValueChanged<int> onDayToggled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat Days (Empty = Daily)',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: List.generate(7, (index) {
            final dayIndex = index + 1;
            final isSelected = selectedDays.contains(dayIndex);
            return ChoiceChip(
              label: Text(_weekdayNames[index]),
              selected: isSelected,
              onSelected: (_) => onDayToggled(dayIndex),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPreviewAndTestRow({
    required ThemeData theme,
    required String previewText,
    required VoidCallback onTestTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            previewText,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onTestTap,
          icon: const Icon(Icons.bolt_rounded, size: 16),
          label: const Text('Test'),
        ),
      ],
    );
  }

  String _formatTimeStr(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayH = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayH.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _triggerTestNotification(ReminderModel reminder) async {
    final isBedtime = reminder.id == 'bedtime';
    
    // Stop any previous test alarms
    await Alarm.stop(9999);

    final triggerTime = DateTime.now().add(const Duration(seconds: 5));
    
    String audioPath = 'assets/water_remainder.mp3';
    if (isBedtime) {
      audioPath = 'assets/bedtime.mp3';
    } else if (reminder.id == 'wakeup') {
      audioPath = 'assets/wakeupalarm.mp3';
    }

    final alarmSettings = AlarmSettings(
      id: 9999, // Test alarm ID
      dateTime: triggerTime,
      assetAudioPath: audioPath,
      loopAudio: false,
      vibrate: reminder.vibrate,
      volumeSettings: const VolumeSettings.fixed(volume: 0.7),
      notificationSettings: NotificationSettings(
        title: '⏰ Test Alert: ${reminder.title}',
        body: reminder.body,
        stopButton: 'Dismiss',
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }
}
