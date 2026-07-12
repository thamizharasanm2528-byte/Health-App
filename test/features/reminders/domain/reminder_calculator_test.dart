import 'package:flutter_test/flutter_test.dart';
import 'package:health_companion/features/reminders/data/reminder_model.dart';
import 'package:health_companion/features/reminders/domain/reminder_calculator.dart';

void main() {
  group('ReminderCalculator Unit Tests', () {
    test('getNextOccurrence returns null if reminder is disabled', () {
      final reminder = ReminderModel(
        id: 'water',
        type: 'water',
        title: 'Drink Water',
        body: 'Stay hydrated!',
        isEnabled: false,
        reminderTimes: [480], // 8:00 AM
        repeatDays: [],
      );

      final next = ReminderCalculator.getNextOccurrence(reminder, DateTime(2026, 7, 12, 6, 0));
      expect(next, isNull);
    });

    test('getNextOccurrence returns null if reminderTimes is empty', () {
      final reminder = ReminderModel(
        id: 'water',
        type: 'water',
        title: 'Drink Water',
        body: 'Stay hydrated!',
        isEnabled: true,
        reminderTimes: [],
        repeatDays: [],
      );

      final next = ReminderCalculator.getNextOccurrence(reminder, DateTime(2026, 7, 12, 6, 0));
      expect(next, isNull);
    });

    test('getNextOccurrence returns next scheduled time today', () {
      final reminder = ReminderModel(
        id: 'water',
        type: 'water',
        title: 'Drink Water',
        body: 'Stay hydrated!',
        isEnabled: true,
        reminderTimes: [480, 600, 720], // 8:00 AM, 10:00 AM, 12:00 PM
        repeatDays: [],
      );

      // Calculations:
      // Current time is 9:00 AM (540 minutes).
      // Available slots are 8:00 AM (480), 10:00 AM (600), 12:00 PM (720).
      // Next slot after 9:00 AM is 10:00 AM (600).
      final baseTime = DateTime(2026, 7, 12, 9, 0); // Sunday (weekday = 7)
      final next = ReminderCalculator.getNextOccurrence(reminder, baseTime);

      expect(next, isNotNull);
      expect(next!.hour, 10);
      expect(next.minute, 0);
      expect(next.day, 12);
    });

    test('getNextOccurrence wraps to next day if all slot times today have passed', () {
      final reminder = ReminderModel(
        id: 'water',
        type: 'water',
        title: 'Drink Water',
        body: 'Stay hydrated!',
        isEnabled: true,
        reminderTimes: [480, 600], // 8:00 AM, 10:00 AM
        repeatDays: [],
      );

      // Calculations:
      // Current time is 11:00 AM (660 minutes).
      // All times (480, 600) have passed.
      // Next scheduled time should wrap to tomorrow (July 13th) at the first slot: 8:00 AM (480).
      final baseTime = DateTime(2026, 7, 12, 11, 0); // Sunday, July 12
      final next = ReminderCalculator.getNextOccurrence(reminder, baseTime);

      expect(next, isNotNull);
      expect(next!.hour, 8);
      expect(next.minute, 0);
      expect(next.day, 13); // Monday, July 13
    });

    test('getNextOccurrence schedules for specific weekday repeat selection', () {
      final reminder = ReminderModel(
        id: 'water',
        type: 'water',
        title: 'Drink Water',
        body: 'Stay hydrated!',
        isEnabled: true,
        reminderTimes: [480], // 8:00 AM
        repeatDays: [1, 3, 5], // Monday (1), Wednesday (3), Friday (5)
      );

      // Calculations:
      // Current time is Saturday, July 11th (weekday = 6), at 10:00 AM.
      // Repeating slots are Mon (1), Wed (3), Fri (5).
      // Next valid repeating day is Monday, July 13th (2 days out), at 8:00 AM (480).
      final baseTime = DateTime(2026, 7, 11, 10, 0); // Saturday, July 11
      final next = ReminderCalculator.getNextOccurrence(reminder, baseTime);

      expect(next, isNotNull);
      expect(next!.hour, 8);
      expect(next.minute, 0);
      expect(next.day, 13); // Monday, July 13 (weekday = 1)
    });
  });
}
