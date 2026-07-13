import 'package:flutter/material.dart';
import '../../data/alarm_settings_model.dart';
import '../alarm_provider.dart';

Future<void> showAddEditAlarmSheet(
  BuildContext context,
  AlarmProvider alarmProv,
  AlarmSettingsModel? alarm,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return _AddEditAlarmSheetContent(
        alarmProv: alarmProv,
        alarm: alarm,
      );
    },
  );
}

class _AddEditAlarmSheetContent extends StatefulWidget {
  final AlarmProvider alarmProv;
  final AlarmSettingsModel? alarm;

  const _AddEditAlarmSheetContent({
    required this.alarmProv,
    required this.alarm,
  });

  @override
  State<_AddEditAlarmSheetContent> createState() => _AddEditAlarmSheetContentState();
}

class _AddEditAlarmSheetContentState extends State<_AddEditAlarmSheetContent> {
  late int selectedHour;
  late int selectedMinute;
  late List<int> tempRepeatDays;
  late bool sound;
  late bool vibrate;
  late int snoozeMinutes;
  late TextEditingController labelController;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.alarm?.hour ?? 7;
    selectedMinute = widget.alarm?.minute ?? 0;
    tempRepeatDays = List.from(widget.alarm?.repeatDays ?? []);
    sound = widget.alarm?.sound ?? true;
    vibrate = widget.alarm?.vibrate ?? true;
    snoozeMinutes = widget.alarm?.snoozeDurationMinutes ?? 10;
    labelController = TextEditingController(text: widget.alarm?.label ?? '');
  }

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.alarm != null;
    final timeOfDay = TimeOfDay(hour: selectedHour, minute: selectedMinute);
    final formattedTime = widget.alarmProv.formatTimeOfDay(selectedHour, selectedMinute);

    final daysOfWeek = [
      {'label': 'Mon', 'day': 1},
      {'label': 'Tue', 'day': 2},
      {'label': 'Wed', 'day': 3},
      {'label': 'Thu', 'day': 4},
      {'label': 'Fri', 'day': 5},
      {'label': 'Sat', 'day': 6},
      {'label': 'Sun', 'day': 7},
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Wake-up Alarm' : 'New Wake-up Alarm',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // ── Time Selector Card ──
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: timeOfDay,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedHour = pickedTime.hour;
                      selectedMinute = pickedTime.minute;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          formattedTime,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_calendar_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            'Tap to select alarm time',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Alarm Label Field ──
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: 'Label / Name',
                prefixIcon: const Icon(Icons.label_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                hintText: 'e.g. Work, Morning Workout',
              ),
            ),
            const SizedBox(height: 20),

            // ── Repeat days group ──
            Text(
              'Repeat Days',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: daysOfWeek.map((dayMap) {
                final label = dayMap['label'] as String;
                final dayVal = dayMap['day'] as int;
                final isSelected = tempRepeatDays.contains(dayVal);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (tempRepeatDays.contains(dayVal)) {
                        tempRepeatDays.remove(dayVal);
                      } else {
                        tempRepeatDays.add(dayVal);
                      }
                    });
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        child: Text(
                          label[0],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Snooze Duration ──
            DropdownButtonFormField<int>(
              initialValue: snoozeMinutes,
              decoration: InputDecoration(
                labelText: 'Snooze Duration',
                prefixIcon: const Icon(Icons.snooze_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 minutes')),
                DropdownMenuItem(value: 10, child: Text('10 minutes')),
                DropdownMenuItem(value: 15, child: Text('15 minutes')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    snoozeMinutes = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // ── Sound & Vibration switches ──
            SwitchListTile.adaptive(
              title: const Text('Play Audio Sound'),
              subtitle: const Text('Rings custom sound on alarm trigger', style: TextStyle(fontSize: 11)),
              value: sound,
              onChanged: (val) => setState(() => sound = val),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile.adaptive(
              title: const Text('Continuous Vibration'),
              subtitle: const Text('Vibrates the device until stopped', style: TextStyle(fontSize: 11)),
              value: vibrate,
              onChanged: (val) => setState(() => vibrate = val),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ──
            Row(
              children: [
                if (isEdit)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        await widget.alarmProv.deleteAlarm(widget.alarm!.id);
                        nav.pop();
                      },
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                      label: const Text('DELETE', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                if (isEdit) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(context);
                      try {
                        if (isEdit) {
                          final updated = widget.alarm!.copyWith(
                            hour: selectedHour,
                            minute: selectedMinute,
                            repeatDays: tempRepeatDays,
                            sound: sound,
                            vibrate: vibrate,
                            snoozeDurationMinutes: snoozeMinutes,
                            label: labelController.text.trim(),
                          );
                          await widget.alarmProv.updateAlarm(updated);
                        } else {
                          final newAlarm = AlarmSettingsModel(
                            isEnabled: true,
                            hour: selectedHour,
                            minute: selectedMinute,
                            repeatDays: tempRepeatDays,
                            sound: sound,
                            vibrate: vibrate,
                            snoozeDurationMinutes: snoozeMinutes,
                            label: labelController.text.trim(),
                          );
                          await widget.alarmProv.addAlarm(newAlarm);
                        }
                        // Optionally sync bedtime if preferred
                        await widget.alarmProv.syncBedtimeWithWakeTime(selectedHour, selectedMinute);
                        nav.pop();
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Error saving alarm: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        nav.pop();
                      }
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      isEdit ? 'SAVE CHANGES' : 'CREATE ALARM',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
