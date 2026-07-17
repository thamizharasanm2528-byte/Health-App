import 'package:alarm/alarm.dart';
import '../data/alarm_settings_model.dart';

class AlarmEngine {
  // Base IDs
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
    final body = alarm.label.isNotEmpty
        ? alarm.label
        : 'Stay consistent with your healthy routine.';

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
