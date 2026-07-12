import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/reminder_model.dart';
import '../domain/reminder_engine.dart';

class RemindersProvider extends ChangeNotifier {
  static const String boxName = 'reminders_box';
  
  late Box<ReminderModel> _box;
  final ReminderEngine _engine = ReminderEngine();

  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => _reminders;

  RemindersProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<ReminderModel>(boxName);
    _loadReminders();
    _box.watch().listen((_) {
      _loadReminders();
    });
  }

  void _loadReminders() {
    _reminders = _box.values.toList();
    notifyListeners();
  }

  /// Gets a reminder by its ID, returning a default one if not found.
  ReminderModel getReminderById(String id, {
    required String type,
    required String title,
    required String body,
    required List<int> defaultTimes,
  }) {
    final existing = _reminders.firstWhere((r) => r.id == id, orElse: () {
      final newReminder = ReminderModel(
        id: id,
        type: type,
        title: title,
        body: body,
        isEnabled: false,
        reminderTimes: defaultTimes,
        repeatDays: [],
        sound: true,
        vibrate: true,
      );
      _box.put(id, newReminder);
      return newReminder;
    });
    if (!_reminders.any((r) => r.id == id)) {
      _reminders.add(existing);
    }
    return existing;
  }

  /// Saves or updates a reminder.
  Future<void> saveReminder(ReminderModel reminder) async {
    await _box.put(reminder.id, reminder);
    _loadReminders();
    await _engine.rescheduleReminder(reminder);
  }

  /// Reschedules all reminders (e.g. on app startup).
  Future<void> rescheduleAll() async {
    for (final reminder in _reminders) {
      if (reminder.isEnabled) {
        await _engine.rescheduleReminder(reminder);
      } else {
        await _engine.cancelReminder(reminder.id);
      }
    }
  }

  /// Deletes a custom reminder.
  Future<void> deleteReminder(String id) async {
    await _engine.cancelReminder(id);
    await _box.delete(id);
    _loadReminders();
  }

  /// Calculates the next occurrence of a reminder.
  DateTime? getNextOccurrence(ReminderModel reminder) {
    if (!reminder.isEnabled || reminder.reminderTimes.isEmpty) return null;
    
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    final sortedTimes = List<int>.from(reminder.reminderTimes)..sort();
    
    // Check if there's any time slot left today
    for (final time in sortedTimes) {
      if (time > currentMinutes) {
        if (reminder.repeatDays.isEmpty || reminder.repeatDays.contains(now.weekday)) {
          return DateTime(now.year, now.month, now.day, time ~/ 60, time % 60);
        }
      }
    }
    
    // Check coming days (up to 7 days out)
    for (int i = 1; i <= 7; i++) {
      final targetDate = now.add(Duration(days: i));
      if (reminder.repeatDays.isEmpty || reminder.repeatDays.contains(targetDate.weekday)) {
        final time = sortedTimes.first;
        return DateTime(targetDate.year, targetDate.month, targetDate.day, time ~/ 60, time % 60);
      }
    }
    
    return null;
  }

  /// Formats the next scheduled occurrence of a reminder for display.
  String getNextReminderText(String id) {
    final reminder = _reminders.firstWhere((r) => r.id == id, orElse: () {
      final backup = _box.get(id);
      if (backup != null) return backup;
      return ReminderModel(id: id, type: '', title: '', body: '', isEnabled: false, reminderTimes: [], repeatDays: []);
    });
    
    if (!reminder.isEnabled) return 'Off';
    final next = getNextOccurrence(reminder);
    if (next == null) return 'Off';
    
    final now = DateTime.now();
    final isToday = next.day == now.day && next.month == now.month && next.year == now.year;
    final isTomorrow = next.day == now.add(const Duration(days: 1)).day && next.month == now.month && next.year == now.year;
    
    final hour = next.hour;
    final minute = next.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayH = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final timeStr = '${displayH.toString()}:${minute.toString().padLeft(2, '0')} $period';
    
    if (isToday) return 'Today, $timeStr';
    if (isTomorrow) return 'Tomorrow, $timeStr';
    
    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdayNames[next.weekday - 1]}, $timeStr';
  }


}
