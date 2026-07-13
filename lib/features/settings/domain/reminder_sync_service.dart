import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/services/notifications/notification_manager.dart';
import '../../../core/services/notifications/notification_service.dart';
import '../../../core/services/notifications/notification_constants.dart';
import '../../profile/data/profile_model.dart';
import '../data/settings_model.dart';

class ReminderSyncService {
  final NotificationManager _notificationManager = NotificationManager();

  Future<void> toggleReminderBackground({
    required String type,
    required bool val,
    required bool masterNotificationsEnabled,
    required ProfileModel profile,
  }) async {
    switch (type) {
      case 'water':
        if (val && masterNotificationsEnabled) {
          await _notificationManager.scheduleWaterReminder(intervalMinutes: 60, startHour: 8, endHour: 22);
        } else {
          await _notificationManager.cancelWaterReminders();
        }
        break;

      case 'bedtime':
        if (val && masterNotificationsEnabled) {
          await _notificationManager.scheduleSleepReminder(
            hour: profile.bedtimeMinutes ~/ 60,
            minute: profile.bedtimeMinutes % 60,
            offsetMinutes: 30,
          );
        } else {
          await _notificationManager.cancelSleepReminders();
        }
        break;
      case 'wakeup':
        if (val && masterNotificationsEnabled) {
          await _notificationManager.scheduleWakeUpReminder(
            hour: profile.wakeTimeMinutes ~/ 60,
            minute: profile.wakeTimeMinutes % 60,
          );
        } else {
          await _notificationManager.cancelWakeUpReminders();
        }
        break;
      case 'report':
        if (val && masterNotificationsEnabled) {
          const androidDetails = AndroidNotificationDetails(
            NotificationConstants.channelGeneralId,
            NotificationConstants.channelGeneralName,
            channelDescription: NotificationConstants.channelGeneralDesc,
            importance: Importance.high,
            priority: Priority.high,
          );
          await NotificationService.instance.scheduler.scheduleWeekly(
            id: 9999,
            title: '📈 Weekly Health Report!',
            body: 'Check out your hydration, sleep consistency, and progress rates.',
            weekday: 7, // Sunday
            hour: 9,
            minute: 0,
            details: const NotificationDetails(android: androidDetails),
          );
        } else {
          await _notificationManager.cancelReminder(9999);
        }
        break;
    }
  }

  Future<void> syncAllRemindersWithManager({
    required SettingsModel settings,
    required ProfileModel profile,
  }) async {
    if (settings.waterNotificationsEnabled) {
      await _notificationManager.scheduleWaterReminder(intervalMinutes: 60, startHour: 8, endHour: 22);
    }
    if (settings.bedtimeNotificationsEnabled) {
      await _notificationManager.scheduleSleepReminder(
        hour: profile.bedtimeMinutes ~/ 60,
        minute: profile.bedtimeMinutes % 60,
        offsetMinutes: 30,
      );
    }
    if (settings.wakeupNotificationsEnabled) {
      await _notificationManager.scheduleWakeUpReminder(
        hour: profile.wakeTimeMinutes ~/ 60,
        minute: profile.wakeTimeMinutes % 60,
      );
    }
  }

  Future<void> cancelAll() async {
    await _notificationManager.cancelAll();
  }
}
