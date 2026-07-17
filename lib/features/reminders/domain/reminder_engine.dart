import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/reminder_model.dart';
import '../../../core/services/notifications/notification_service.dart';
import '../../../core/services/notifications/notification_constants.dart';

class ReminderEngine {
  static const int waterBaseId = 10000;
  static const int bedtimeBaseId = 20000;
  static const int wakeupBaseId = 30000;

  /// Reschedules reminders matching settings.
  Future<void> rescheduleReminder(ReminderModel reminder) async {
    // 1. Cancel previous scheduled items first
    await cancelReminder(reminder.id);

    if (!reminder.isEnabled || reminder.reminderTimes.isEmpty) return;

    final playSound = reminder.sound;
    final enableVibration = reminder.vibrate;

    String customSound;
    int baseId;

    if (reminder.id == 'water') {
      customSound = 'water_remainder';
      baseId = waterBaseId;
    } else if (reminder.id == 'bedtime') {
      customSound = 'bedtime';
      baseId = bedtimeBaseId;
    } else if (reminder.id == 'wakeup_reminder') {
      customSound = 'wakeupalarm';
      baseId = wakeupBaseId;
    } else {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      NotificationConstants.channelReminderId,
      NotificationConstants.channelReminderName,
      channelDescription: NotificationConstants.channelReminderDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: playSound,
      sound: playSound ? RawResourceAndroidNotificationSound(customSound) : null,
      vibrationPattern: enableVibration ? Int64List.fromList([0, 1000, 500, 1000]) : null,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
      sound: playSound ? '$customSound.mp3' : null,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    final scheduler = NotificationService.instance.scheduler;

    for (final timeInMinutes in reminder.reminderTimes) {
      final hour = timeInMinutes ~/ 60;
      final minute = timeInMinutes % 60;

      if (reminder.repeatDays.isEmpty) {
        // Daily repeat
        final id = baseId + timeInMinutes;
        await scheduler.scheduleDaily(
          id: id,
          title: reminder.title,
          body: reminder.body,
          hour: hour,
          minute: minute,
          details: details,
        );
      } else {
        // Repeat on selected weekdays
        for (final day in reminder.repeatDays) {
          final id = baseId + (day * 2000) + timeInMinutes;
          await scheduler.scheduleWeekly(
            id: id,
            title: reminder.title,
            body: reminder.body,
            weekday: day,
            hour: hour,
            minute: minute,
            details: details,
          );
        }
      }
    }
  }

  /// Cancels a specific reminder.
  Future<void> cancelReminder(String id) async {
    if (id != 'water' && id != 'bedtime' && id != 'wakeup_reminder') {
      return;
    }

    final plugin = NotificationService.instance.plugin;
    final pendingRequests = await plugin.pendingNotificationRequests();
    for (final request in pendingRequests) {
      final reqId = request.id;
      if (id == 'water' && reqId >= waterBaseId && reqId < bedtimeBaseId) {
        await plugin.cancel(id: reqId);
      } else if (id == 'bedtime' && reqId >= bedtimeBaseId && reqId < wakeupBaseId) {
        await plugin.cancel(id: reqId);
      } else if (id == 'wakeup_reminder' && reqId >= wakeupBaseId && reqId < (wakeupBaseId + 10000)) {
        await plugin.cancel(id: reqId);
      }
    }
  }
}
