import 'package:timezone/timezone.dart' as tz;

/// Dates and ID allocation helpers for the notification scheduler.
abstract final class NotificationHelper {
  /// Converts a standard [DateTime] to a [tz.TZDateTime] using local location context.
  static tz.TZDateTime toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Calculates the next occurrence of a given hour/minute.
  /// If the time has passed today, returns tomorrow's date.
  static DateTime nextOccurrence(int hour, int minute) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Calculates the next occurrence for a specific weekday.
  /// [weekday] — 1 (Monday) to 7 (Sunday).
  static DateTime nextWeekdayOccurrence(int weekday, int hour, int minute) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ── ID Allocations ──
  static const int waterBaseId = 1000;
  static const int bedtimeBaseId = 2000;
  static const int wakeUpBaseId = 3000;
  static const int foodBaseId = 4000;
  static const int walkBaseId = 5000;
  static const int weightBaseId = 6000;
  static const int reportBaseId = 7000;

  /// Generates a unique notification ID for a specific food snack based on its hash.
  static int getFoodNotificationId(String foodId) {
    return foodBaseId + (foodId.hashCode % 1000).abs();
  }
}
