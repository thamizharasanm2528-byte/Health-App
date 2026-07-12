import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';

import '../../../features/settings/data/settings_model.dart';
import '../../../features/reminders/data/reminder_model.dart';
import '../../../features/reminders/domain/reminder_engine.dart';
import '../../../features/reminders/presentation/reminders_provider.dart';
import 'notification_constants.dart';
import 'notification_service.dart';

/// Central manager interface exposing scheduling and updates APIs for all app features.
class NotificationManager {
  final NotificationService _service = NotificationService.instance;
  final ReminderEngine _engine = ReminderEngine();

  /// Helper to fetch app settings from Hive.
  SettingsModel _getSettings() {
    try {
      final box = Hive.box<SettingsModel>('settings_box');
      return box.get('app_settings') ?? SettingsModel();
    } catch (_) {
      return SettingsModel();
    }
  }

  /// Helper to get reminders Hive box.
  Box<ReminderModel> _getRemindersBox() {
    return Hive.box<ReminderModel>(RemindersProvider.boxName);
  }

  // ── Water Scheduling ──────────────────────────────────────────────────

  /// Schedules daily water alerts window.
  Future<void> scheduleWaterReminder({
    required int intervalMinutes,
    required int startHour,
    required int endHour,
  }) async {
    final settings = _getSettings();
    final bool isEnabled = settings.masterNotificationsEnabled && settings.waterNotificationsEnabled;

    final playSound = settings.waterSoundEnabled;
    final enableVibration = settings.waterVibrationEnabled;

    // Generate times
    final times = <int>[];
    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute = 0; minute < 60; minute += intervalMinutes) {
        times.add(hour * 60 + minute);
      }
    }

    final reminder = ReminderModel(
      id: 'water',
      type: 'water',
      title: '💧 Time to Drink Water!',
      body: 'Stay hydrated — your body will thank you.',
      isEnabled: isEnabled,
      reminderTimes: times,
      repeatDays: [], // Daily
      sound: playSound,
      vibrate: enableVibration,
    );

    final box = _getRemindersBox();
    await box.put('water', reminder);
    await _engine.rescheduleReminder(reminder);
  }

  /// Cancels all water reminders.
  Future<void> cancelWaterReminders() async {
    final box = _getRemindersBox();
    final reminder = box.get('water');
    if (reminder != null) {
      reminder.isEnabled = false;
      await box.put('water', reminder);
    }
    await _engine.cancelReminder('water');
  }

  // ── Bedtime Scheduling ─────────────────────────────────────────────────

  /// Schedules bedtime sleep reminder daily.
  Future<void> scheduleSleepReminder({
    required int hour,
    required int minute,
    required int offsetMinutes,
  }) async {
    final settings = _getSettings();
    final bool isEnabled = settings.masterNotificationsEnabled && settings.bedtimeNotificationsEnabled;

    final playSound = settings.bedtimeSoundEnabled;
    final enableVibration = settings.bedtimeVibrationEnabled;

    var totalMinutes = hour * 60 + minute - offsetMinutes;
    if (totalMinutes < 0) totalMinutes += 1440;

    final reminder = ReminderModel(
      id: 'bedtime',
      type: 'bedtime',
      title: '🛌 Bedtime is approaching!',
      body: 'Wind down and prepare for a restful sleep.',
      isEnabled: isEnabled,
      reminderTimes: [totalMinutes],
      repeatDays: [], // Daily
      sound: playSound,
      vibrate: enableVibration,
    );

    final box = _getRemindersBox();
    await box.put('bedtime', reminder);
    await _engine.rescheduleReminder(reminder);
  }

  /// Cancels sleep reminders.
  Future<void> cancelSleepReminders() async {
    final box = _getRemindersBox();
    final reminder = box.get('bedtime');
    if (reminder != null) {
      reminder.isEnabled = false;
      await box.put('bedtime', reminder);
    }
    await _engine.cancelReminder('bedtime');
  }

  // ── Wake-up Scheduling ─────────────────────────────────────────────────

  /// Schedules daily wake up reminder (log reminder).
  Future<void> scheduleWakeUpReminder({
    required int hour,
    required int minute,
  }) async {
    final settings = _getSettings();
    final bool isEnabled = settings.masterNotificationsEnabled && settings.wakeupNotificationsEnabled;

    final playSound = settings.wakeupSoundEnabled;
    final enableVibration = settings.wakeupVibrationEnabled;

    final reminder = ReminderModel(
      id: 'wakeup_reminder',
      type: 'bedtime',
      title: '🌅 Good Morning!',
      body: 'Time to wake up and start your day healthy.',
      isEnabled: isEnabled,
      reminderTimes: [hour * 60 + minute],
      repeatDays: [], // Daily
      sound: playSound,
      vibrate: enableVibration,
    );

    final box = _getRemindersBox();
    await box.put('wakeup_reminder', reminder);
    await _engine.rescheduleReminder(reminder);
  }

  /// Cancels wake reminders.
  Future<void> cancelWakeUpReminders() async {
    final box = _getRemindersBox();
    final reminder = box.get('wakeup_reminder');
    if (reminder != null) {
      reminder.isEnabled = false;
      await box.put('wakeup_reminder', reminder);
    }
    await _engine.cancelReminder('wakeup_reminder');
  }



  // ── General Operations ──

  /// Cancels specific scheduled reminder.
  Future<void> cancelReminder(int id) async {
    await _service.scheduler.cancel(id);
  }

  /// Cancels all scheduled alerts.
  Future<void> cancelAll() async {
    await _service.scheduler.cancelAll();
    final box = _getRemindersBox();
    for (final reminder in box.values) {
      reminder.isEnabled = false;
      await box.put(reminder.id, reminder);
    }
  }

  /// Snoozes/Delays the alert by X minutes.
  Future<void> snoozeReminder(int id, int minutes) async {
    final snoozeTime = DateTime.now().add(Duration(minutes: minutes));

    final androidDetails = AndroidNotificationDetails(
      NotificationConstants.channelReminderId,
      NotificationConstants.channelReminderName,
      channelDescription: NotificationConstants.channelReminderDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    final details = NotificationDetails(android: androidDetails);

    await _service.scheduler.scheduleOneTime(
      id: id,
      title: '⏰ [Snoozed Alert]',
      body: 'Time to log your healthy updates.',
      scheduledDate: snoozeTime,
      details: details,
    );
  }

  /// Displays an immediate local notification (for level up, badge unlock, streak milestone).
  Future<void> showStreakNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      NotificationConstants.channelAchievementsId,
      NotificationConstants.channelAchievementsName,
      channelDescription: NotificationConstants.channelAchievementsDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    await _service.plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
