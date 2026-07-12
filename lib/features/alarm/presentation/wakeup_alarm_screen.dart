import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/notifications/notification_permission_service.dart';
import '../../../core/services/notifications/notification_service.dart';
import '../data/alarm_settings_model.dart';
import 'alarm_provider.dart';

class WakeupAlarmScreen extends StatelessWidget {
  const WakeupAlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alarmProv = context.watch<AlarmProvider>();
    final alarms = alarmProv.alarms;

    if (alarmProv.lastError != null) {
      final error = alarmProv.lastError!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        alarmProv.clearLastError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.alarm_rounded, color: AppColors.sleep, size: 24),
            const SizedBox(width: 10),
            Text(
              'Alarms List',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm_off_rounded,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alarms set yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add your first alarm.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return _buildAlarmTile(context, alarm, alarmProv, theme);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditAlarmSheet(context, alarmProv, null),
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Add Alarm'),
      ),
    );
  }

  Widget _buildAlarmTile(
    BuildContext context,
    AlarmSettingsModel alarm,
    AlarmProvider alarmProv,
    ThemeData theme,
  ) {
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
        onTap: () => _showAddEditAlarmSheet(context, alarmProv, alarm),
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
                    onChanged: (val) => _handleAlarmToggle(context, alarmProv, alarm.id, val),
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
                        onPressed: () => alarmProv.deleteAlarm(alarm.id),
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

  Future<void> _showAddEditAlarmSheet(
    BuildContext context,
    AlarmProvider alarmProv,
    AlarmSettingsModel? alarm,
  ) async {
    final theme = Theme.of(context);
    final isEdit = alarm != null;

    int selectedHour = alarm?.hour ?? 7;
    int selectedMinute = alarm?.minute ?? 0;
    List<int> tempRepeatDays = List.from(alarm?.repeatDays ?? []);
    bool sound = alarm?.sound ?? true;
    bool vibrate = alarm?.vibrate ?? true;
    int snoozeMinutes = alarm?.snoozeDurationMinutes ?? 10;
    final labelController = TextEditingController(text: alarm?.label ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final timeOfDay = TimeOfDay(hour: selectedHour, minute: selectedMinute);
            final formattedTime = alarmProv.formatTimeOfDay(selectedHour, selectedMinute);

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
                            setModalState(() {
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
                            setModalState(() {
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
                          setModalState(() {
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
                      onChanged: (val) => setModalState(() => sound = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile.adaptive(
                      title: const Text('Continuous Vibration'),
                      subtitle: const Text('Vibrates the device until stopped', style: TextStyle(fontSize: 11)),
                      value: vibrate,
                      onChanged: (val) => setModalState(() => vibrate = val),
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
                                await alarmProv.deleteAlarm(alarm.id);
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
                                  final updated = alarm.copyWith(
                                    hour: selectedHour,
                                    minute: selectedMinute,
                                    repeatDays: tempRepeatDays,
                                    sound: sound,
                                    vibrate: vibrate,
                                    snoozeDurationMinutes: snoozeMinutes,
                                    label: labelController.text.trim(),
                                  );
                                  await alarmProv.updateAlarm(updated);
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
                                  await alarmProv.addAlarm(newAlarm);
                                }
                                // Optionally sync bedtime if preferred
                                await alarmProv.syncBedtimeWithWakeTime(selectedHour, selectedMinute);
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
          },
        );
      },
    );
  }

  Future<void> _handleAlarmToggle(
    BuildContext context,
    AlarmProvider alarmProv,
    int alarmId,
    bool val,
  ) async {
    final status = await alarmProv.toggleAlarm(alarmId, val);
    if (status == AppPermissionStatus.permanentlyDenied && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Exact Alarm and Notification permissions are required to schedule background alarms. '
            'Please grant these permissions in your system settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                NotificationService.instance.permissionService.openSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }
}
