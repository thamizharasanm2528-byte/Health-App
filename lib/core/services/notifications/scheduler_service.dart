import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_helper.dart';

class SchedulerService {
  final FlutterLocalNotificationsPlugin _plugin;

  SchedulerService(this._plugin);

  /// Helper to convert DateTime to TZDateTime.
  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Helper to safely schedule zoned notifications with a fallback to inexact timing if permission is denied.
  Future<void> _safeZonedSchedule({
    required int id,
    required String? title,
    required String? body,
    required DateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _toTZDateTime(scheduledDate),
        notificationDetails: notificationDetails,
        androidScheduleMode: androidScheduleMode,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
    } catch (e) {
      if (androidScheduleMode == AndroidScheduleMode.exactAllowWhileIdle ||
          androidScheduleMode == AndroidScheduleMode.exact) {
        try {
          await _plugin.zonedSchedule(
            id: id,
            title: title,
            body: body,
            scheduledDate: _toTZDateTime(scheduledDate),
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: matchDateTimeComponents,
            payload: payload,
          );
        } catch (_) {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  /// Schedules a one-time notification.
  Future<void> scheduleOneTime({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationDetails details,
    String? payload,
  }) async {
    await _safeZonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Schedules a daily repeating notification.
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required NotificationDetails details,
    String? payload,
  }) async {
    final nextTime = NotificationHelper.nextOccurrence(hour, minute);
    await _safeZonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: nextTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// Schedules a weekly repeating notification on a specific day.
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday, // 1 = Mon, 7 = Sun
    required int hour,
    required int minute,
    required NotificationDetails details,
    String? payload,
  }) async {
    final nextTime = NotificationHelper.nextWeekdayOccurrence(weekday, hour, minute);
    await _safeZonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: nextTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  /// Cancels a specific scheduled alert.
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Cancels all scheduled alerts.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
