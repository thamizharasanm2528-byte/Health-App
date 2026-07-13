import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/notifications/notification_permission_service.dart';
import '../../../core/services/notifications/notification_service.dart';
import '../data/alarm_settings_model.dart';
import 'alarm_provider.dart';
import 'widgets/alarm_tile.dart';
import 'widgets/add_edit_alarm_sheet.dart';

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
                return AlarmTile(
                  alarm: alarm,
                  alarmProv: alarmProv,
                  onTap: () => showAddEditAlarmSheet(context, alarmProv, alarm),
                  onToggle: (val) => _handleAlarmToggle(context, alarmProv, alarm.id, val),
                  onDelete: () => alarmProv.deleteAlarm(alarm.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddEditAlarmSheet(context, alarmProv, null),
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Add Alarm'),
      ),
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
