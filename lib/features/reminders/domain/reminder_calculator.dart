import '../../data/reminder_model.dart';

/// Pure calculator helper to compute scheduled reminder dates without platform IO dependencies.
class ReminderCalculator {
  /// Calculates the next occurrence of a reminder from a given base time.
  static DateTime? getNextOccurrence(ReminderModel reminder, DateTime baseTime) {
    if (!reminder.isEnabled || reminder.reminderTimes.isEmpty) return null;
    
    final currentMinutes = baseTime.hour * 60 + baseTime.minute;
    final sortedTimes = List<int>.from(reminder.reminderTimes)..sort();
    
    // Check if there's any time slot left today
    for (final time in sortedTimes) {
      if (time > currentMinutes) {
        if (reminder.repeatDays.isEmpty || reminder.repeatDays.contains(baseTime.weekday)) {
          return DateTime(baseTime.year, baseTime.month, baseTime.day, time ~/ 60, time % 60);
        }
      }
    }
    
    // Check coming days (up to 7 days out)
    for (int i = 1; i <= 7; i++) {
      final targetDate = baseTime.add(Duration(days: i));
      if (reminder.repeatDays.isEmpty || reminder.repeatDays.contains(targetDate.weekday)) {
        final time = sortedTimes.first;
        return DateTime(targetDate.year, targetDate.month, targetDate.day, time ~/ 60, time % 60);
      }
    }
    
    return null;
  }
}
