import '../data/reminder_model.dart';
import '../../alarm/domain/alarm_engine.dart';

class ReminderEngine {
  final AlarmEngine _alarmEngine = AlarmEngine();

  /// Reschedules reminders matching settings.
  Future<void> rescheduleReminder(ReminderModel reminder) async {
    if (reminder.id == 'water') {
      await _alarmEngine.scheduleWaterReminder(reminder);
    } else if (reminder.id == 'bedtime') {
      await _alarmEngine.scheduleBedtimeReminder(reminder);
    } else if (reminder.id == 'wakeup_reminder') {
      await _alarmEngine.scheduleWakeUpReminder(reminder);
    }
  }

  /// Cancels a specific reminder.
  Future<void> cancelReminder(String id) async {
    if (id == 'water') {
      await _alarmEngine.cancelWaterReminders();
    } else if (id == 'bedtime') {
      await _alarmEngine.cancelBedtimeReminders();
    } else if (id == 'wakeup_reminder') {
      await _alarmEngine.cancelWakeUpReminders();
    }
  }
}
