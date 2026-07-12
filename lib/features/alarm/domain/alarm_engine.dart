import 'package:alarm/alarm.dart';
import '../data/alarm_settings_model.dart';
import '../../reminders/data/reminder_model.dart';

class AlarmEngine {
  // Base IDs
  static const int waterBaseId = 100000;
  static const int bedtimeBaseId = 200000;
  static const int wakeupBaseId = 300000;
  static const int snoozeOffset = 8; // Alarm ID + 8 is snooze
  static const int testAlarmId = 999999;

  /// Helper to calculate next weekday date.
  DateTime _getNextWeekdayDate(int weekday, int hour, int minute) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    var daysOffset = weekday - now.weekday;
    if (daysOffset < 0 || (daysOffset == 0 && scheduled.isBefore(now))) {
      daysOffset += 7;
    }
    return scheduled.add(Duration(days: daysOffset));
  }

  /// Reschedules a single Wake-up Alarm.
  Future<void> scheduleWakeupAlarm(AlarmSettingsModel alarm) async {
    // First stop previous schedules for this alarm
    final baseId = wakeupBaseId + (alarm.id % 50000) * 10;
    for (int i = 0; i <= 8; i++) {
      await Alarm.stop(baseId + i);
    }

    if (!alarm.isEnabled) return;

    final hour = alarm.hour;
    final minute = alarm.minute;
    final title = '⏰ Wake up! Time to shine!';
    final body = alarm.label.isNotEmpty ? alarm.label : 'Stay consistent with your healthy routine.';

    if (alarm.repeatDays.isEmpty) {
      // One-time alarm
      final now = DateTime.now();
      var scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      final alarmSettings = AlarmSettings(
        id: baseId,
        dateTime: scheduleTime,
        assetAudioPath: 'assets/wakeupalarm.mp3',
        loopAudio: true,
        vibrate: alarm.vibrate,
        androidFullScreenIntent: true,
        volumeSettings: const VolumeSettings.fixed(volume: 0.8),
        notificationSettings: NotificationSettings(
          title: title,
          body: body,
          stopButton: 'Stop',
        ),
      );
      await Alarm.set(alarmSettings: alarmSettings);
    } else {
      // Repeat weekly on selected weekdays
      for (final day in alarm.repeatDays) {
        final scheduleTime = _getNextWeekdayDate(day, hour, minute);
        final alarmSettings = AlarmSettings(
          id: baseId + day,
          dateTime: scheduleTime,
          assetAudioPath: 'assets/wakeupalarm.mp3',
          loopAudio: true,
          vibrate: alarm.vibrate,
          androidFullScreenIntent: true,
          volumeSettings: const VolumeSettings.fixed(volume: 0.8),
          notificationSettings: NotificationSettings(
            title: title,
            body: body,
            stopButton: 'Stop',
          ),
        );
        await Alarm.set(alarmSettings: alarmSettings);
      }
    }
  }

  /// Cancels all schedules for a specific Wake-up Alarm.
  Future<void> cancelWakeupAlarm(int alarmId) async {
    final baseId = wakeupBaseId + (alarmId % 50000) * 10;
    for (int i = 0; i <= 8; i++) {
      await Alarm.stop(baseId + i);
    }
  }

  /// Snoozes the alarm.
  Future<void> snoozeAlarm(AlarmSettingsModel alarm) async {
    final baseId = wakeupBaseId + (alarm.id % 50000) * 10;
    
    // Stop currently ringing alarms/snoozes for this alarm
    for (int i = 0; i <= 8; i++) {
      await Alarm.stop(baseId + i);
    }

    // Schedule snooze
    final snoozeMinutes = alarm.snoozeDurationMinutes;
    final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMinutes));

    final alarmSettings = AlarmSettings(
      id: baseId + snoozeOffset,
      dateTime: snoozeTime,
      assetAudioPath: 'assets/wakeupalarm.mp3',
      loopAudio: true,
      vibrate: alarm.vibrate,
      androidFullScreenIntent: true,
      volumeSettings: const VolumeSettings.fixed(volume: 0.8),
      notificationSettings: const NotificationSettings(
        title: '⏰ Snoozed: Wake Up!',
        body: 'Time to start your healthy routine.',
        stopButton: 'Stop',
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  /// Dismisses all notifications / ringing for this alarm, and reschedules repeats.
  Future<void> dismissAlarm(AlarmSettingsModel alarm) async {
    final baseId = wakeupBaseId + (alarm.id % 50000) * 10;
    for (int i = 0; i <= 8; i++) {
      await Alarm.stop(baseId + i);
    }
    // Reschedule the main repeat alarms for their next occurrences
    await scheduleWakeupAlarm(alarm);
  }

  // ── Reminders Scheduling ──
  
  /// Reschedules Water reminder times.
  Future<void> scheduleWaterReminder(ReminderModel reminder) async {
    // 1. Cancel previous scheduled items
    await cancelWaterReminders();

    if (!reminder.isEnabled || reminder.reminderTimes.isEmpty) return;

    // 2. Schedule for all reminder times
    for (final timeInMinutes in reminder.reminderTimes) {
      final hour = timeInMinutes ~/ 60;
      final minute = timeInMinutes % 60;

      if (reminder.repeatDays.isEmpty) {
        // Daily repeat
        final now = DateTime.now();
        var scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);
        if (scheduleTime.isBefore(now)) {
          scheduleTime = scheduleTime.add(const Duration(days: 1));
        }

        final alarmSettings = AlarmSettings(
          id: waterBaseId + timeInMinutes,
          dateTime: scheduleTime,
          assetAudioPath: 'assets/water_remainder.mp3',
          loopAudio: false,
          vibrate: reminder.vibrate,
          volumeSettings: const VolumeSettings.fixed(volume: 0.7),
          notificationSettings: NotificationSettings(
            title: reminder.title,
            body: reminder.body,
            stopButton: 'Dismiss',
          ),
        );
        await Alarm.set(alarmSettings: alarmSettings);
      } else {
        // Repeat on selected weekdays
        for (final day in reminder.repeatDays) {
          final scheduleTime = _getNextWeekdayDate(day, hour, minute);
          final alarmSettings = AlarmSettings(
            id: waterBaseId + (day * 2000) + timeInMinutes,
            dateTime: scheduleTime,
            assetAudioPath: 'assets/water_remainder.mp3',
            loopAudio: false,
            vibrate: reminder.vibrate,
            volumeSettings: const VolumeSettings.fixed(volume: 0.7),
            notificationSettings: NotificationSettings(
              title: reminder.title,
              body: reminder.body,
              stopButton: 'Dismiss',
            ),
          );
          await Alarm.set(alarmSettings: alarmSettings);
        }
      }
    }
  }

  /// Cancels all Water reminder schedules.
  Future<void> cancelWaterReminders() async {
    final activeAlarms = await Alarm.getAlarms();
    for (final alarm in activeAlarms) {
      if (alarm.id >= waterBaseId && alarm.id < bedtimeBaseId) {
        await Alarm.stop(alarm.id);
      }
    }
  }

  /// Reschedules Bedtime reminder times.
  Future<void> scheduleBedtimeReminder(ReminderModel reminder) async {
    // 1. Cancel previous scheduled items
    await cancelBedtimeReminders();

    if (!reminder.isEnabled || reminder.reminderTimes.isEmpty) return;

    // 2. Schedule for all reminder times
    for (final timeInMinutes in reminder.reminderTimes) {
      final hour = timeInMinutes ~/ 60;
      final minute = timeInMinutes % 60;

      if (reminder.repeatDays.isEmpty) {
        // Daily repeat
        final now = DateTime.now();
        var scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);
        if (scheduleTime.isBefore(now)) {
          scheduleTime = scheduleTime.add(const Duration(days: 1));
        }

        final alarmSettings = AlarmSettings(
          id: bedtimeBaseId + timeInMinutes,
          dateTime: scheduleTime,
          assetAudioPath: 'assets/bedtime.mp3',
          loopAudio: false,
          vibrate: reminder.vibrate,
          volumeSettings: const VolumeSettings.fixed(volume: 0.6),
          notificationSettings: NotificationSettings(
            title: reminder.title,
            body: reminder.body,
            stopButton: 'Dismiss',
          ),
        );
        await Alarm.set(alarmSettings: alarmSettings);
      } else {
        // Repeat on selected weekdays
        for (final day in reminder.repeatDays) {
          final scheduleTime = _getNextWeekdayDate(day, hour, minute);
          final alarmSettings = AlarmSettings(
            id: bedtimeBaseId + (day * 2000) + timeInMinutes,
            dateTime: scheduleTime,
            assetAudioPath: 'assets/bedtime.mp3',
            loopAudio: false,
            vibrate: reminder.vibrate,
            volumeSettings: const VolumeSettings.fixed(volume: 0.6),
            notificationSettings: NotificationSettings(
              title: reminder.title,
              body: reminder.body,
              stopButton: 'Dismiss',
            ),
          );
          await Alarm.set(alarmSettings: alarmSettings);
        }
      }
    }
  }

  /// Cancels all Bedtime reminder schedules.
  Future<void> cancelBedtimeReminders() async {
    final activeAlarms = await Alarm.getAlarms();
    for (final alarm in activeAlarms) {
      if (alarm.id >= bedtimeBaseId && alarm.id < wakeupBaseId) {
        await Alarm.stop(alarm.id);
      }
    }
  }

  /// Reschedules Wake-up reminder times (daily notification log reminders).
  Future<void> scheduleWakeUpReminder(ReminderModel reminder) async {
    await cancelWakeUpReminders();

    if (!reminder.isEnabled || reminder.reminderTimes.isEmpty) return;

    final hour = reminder.reminderTimes.first ~/ 60;
    final minute = reminder.reminderTimes.first % 60;

    final now = DateTime.now();
    var scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduleTime.isBefore(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: wakeupBaseId - 1000,
      dateTime: scheduleTime,
      assetAudioPath: 'assets/wakeupalarm.mp3',
      loopAudio: false,
      vibrate: reminder.vibrate,
      volumeSettings: const VolumeSettings.fixed(volume: 0.6),
      notificationSettings: NotificationSettings(
        title: reminder.title,
        body: reminder.body,
        stopButton: 'Dismiss',
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  /// Cancels all Wake-up reminder schedules.
  Future<void> cancelWakeUpReminders() async {
    await Alarm.stop(wakeupBaseId - 1000);
  }

  /// Triggers a test alarm in 5 seconds.
  Future<void> triggerTestAlarm(AlarmSettingsModel settings) async {
    await Alarm.stop(testAlarmId);

    final triggerTime = DateTime.now().add(const Duration(seconds: 5));
    final alarmSettings = AlarmSettings(
      id: testAlarmId,
      dateTime: triggerTime,
      assetAudioPath: 'assets/wakeupalarm.mp3',
      loopAudio: true,
      vibrate: settings.vibrate,
      volumeSettings: const VolumeSettings.fixed(volume: 0.8),
      notificationSettings: const NotificationSettings(
        title: '⏰ Test Alarm Ringing!',
        body: 'Your Wake-up Alarm background engine works successfully.',
        stopButton: 'Stop',
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }
}
