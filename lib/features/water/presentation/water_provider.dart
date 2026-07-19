import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../core/services/app_logger.dart';
import '../../reminders/data/reminder_model.dart';

import '../../../core/services/notifications/notification_service.dart';
import '../../../core/services/notifications/notification_permission_service.dart';
import '../../../core/services/notifications/notification_manager.dart';
import '../../../main.dart' show sharedPrefs;
import '../../profile/data/profile_local_data_source.dart';
import '../data/water_entry.dart';
import '../domain/water_repository.dart';

/// State manager for the water tracking feature.
///
/// Manages today's entries, progress calculation, weekly data,
/// streak tracking, and notification scheduling.
class WaterProvider extends ChangeNotifier {
  final WaterRepository _repository;
  final ProfileLocalDataSource _profileDataSource;

  StreamSubscription? _remindersBoxSub;

  String? _lastError;
  String? get lastError => _lastError;

  void clearLastError() {
    if (_lastError != null) {
      _lastError = null;
      notifyListeners();
    }
  }

  WaterProvider(this._repository, this._profileDataSource) {
    _loadData();
    _loadReminderPreferencesCached();
    
    try {
      final box = Hive.box<ReminderModel>('reminders_box');
      _remindersBoxSub = box.watch().listen((_) {
        _loadReminderPreferencesCached();
        notifyListeners();
      });
    } catch (e, st) {
      AppLogger.error('WaterProvider (reminders_box watch)', e, st);
    }

    // Synchronously read the goal alert shown date from Hive to prevent startup race condition
    try {
      final box = Hive.box('app_state');
      _lastAlertShownDate = box.get('water_goal_alert_shown_date') as String? ?? '';
    } catch (e, st) {
      AppLogger.error('WaterProvider constructor (water_goal_alert_shown_date read)', e, st);
    }
  }

  // ── Data ─────────────────────────────────────────────────────────────

  List<WaterEntry> _todayEntries = [];
  List<WaterEntry> get todayEntries => List.unmodifiable(_todayEntries);

  /// Reload data from Hive.
  void _loadData() {
    _todayEntries = _repository.getEntriesForDate(DateTime.now());
    notifyListeners();
  }

  /// Refresh — call after external changes.
  void refresh() {
    _loadData();
    _loadReminderPreferencesCached();
  }

  // ── Progress ─────────────────────────────────────────────────────────

  /// Daily water goal in ml (from profile).
  int get goalMl {
    final profile = _profileDataSource.getProfile();
    return ((profile?.waterGoalLiters ?? 3.0) * 1000).round();
  }

  double get goalLiters => goalMl / 1000;

  /// Today's total intake in ml.
  int get todayIntakeMl =>
      _todayEntries.fold(0, (sum, e) => sum + e.amountMl);

  double get todayIntakeLiters => todayIntakeMl / 1000;

  /// Remaining water in ml.
  int get remainingMl => (goalMl - todayIntakeMl).clamp(0, goalMl * 2);

  double get remainingLiters => remainingMl / 1000;

  /// Progress fraction (0.0 – 1.0+).
  double get progress => goalMl > 0 ? todayIntakeMl / goalMl : 0;

  /// Progress percentage capped at 100.
  int get progressPercent => (progress * 100).round().clamp(0, 999);

  /// Whether goal is met today.
  bool get goalMet => todayIntakeMl >= goalMl;

  // ── CRUD Operations ──────────────────────────────────────────────────

  /// Add a new water entry.
  Future<void> addWater(int amountMl) async {
    final entry = WaterEntry.create(amountMl);
    await _repository.addEntry(entry);
    _loadData();
  }

  /// Update an existing entry's amount.
  Future<void> updateEntry(String id, int newAmountMl) async {
    final entries = _todayEntries.where((e) => e.id == id);
    if (entries.isEmpty) return;
    final entry = entries.first;
    entry.amountMl = newAmountMl;
    await _repository.updateEntry(entry);
    _loadData();
  }

  /// Delete an entry by ID.
  Future<void> deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    _loadData();
  }

  // ── Weekly Analytics ─────────────────────────────────────────────────

  /// Returns the last 7 days of intake as a list of (date, totalMl).
  List<DailyIntake> get weeklyData {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = DateTime(today.year, today.month, today.day - (6 - i));
      final total = _repository.totalForDate(date);
      return DailyIntake(date: date, totalMl: total);
    });
  }

  /// Weekly average in ml.
  int get weeklyAverageMl {
    final data = weeklyData;
    final total = data.fold(0, (sum, d) => sum + d.totalMl);
    final daysWithData = data.where((d) => d.totalMl > 0).length;
    return daysWithData > 0 ? (total / daysWithData).round() : 0;
  }

  /// Highest single-day intake in the last 7 days.
  int get weeklyHighestMl {
    final data = weeklyData;
    if (data.isEmpty) return 0;
    return data.map((d) => d.totalMl).reduce((a, b) => a > b ? a : b);
  }

  /// Lowest single-day intake (non-zero) in the last 7 days.
  int get weeklyLowestMl {
    final data = weeklyData.where((d) => d.totalMl > 0);
    if (data.isEmpty) return 0;
    return data.map((d) => d.totalMl).reduce((a, b) => a < b ? a : b);
  }

  // ── Streak Calculation ───────────────────────────────────────────────

  /// Current consecutive days meeting the water goal (ending today/yesterday).
  int get currentStreak {
    int streak = 0;
    final today = DateTime.now();

    // Start from yesterday (today may not be complete)
    for (int i = 1; i <= 365; i++) {
      final date = DateTime(today.year, today.month, today.day - i);
      final total = _repository.totalForDate(date);
      if (total >= goalMl) {
        streak++;
      } else {
        break;
      }
    }

    // Include today if goal already met
    if (goalMet) streak++;

    return streak;
  }

  /// Best ever consecutive-day streak.
  int get bestStreak {
    final all = _repository.getAllEntries();
    if (all.isEmpty) return currentStreak;

    // Build a set of dates that met the goal
    final metDates = <String>{};
    final byDate = <String, int>{};

    for (final entry in all) {
      final key =
          '${entry.timestamp.year}-${entry.timestamp.month}-${entry.timestamp.day}';
      byDate[key] = (byDate[key] ?? 0) + entry.amountMl;
    }

    for (final kv in byDate.entries) {
      if (kv.value >= goalMl) metDates.add(kv.key);
    }

    // Find longest consecutive run
    int best = 0;
    int current = 0;
    final today = DateTime.now();
    final earliest = all.last.timestamp;
    final daySpan = today.difference(earliest).inDays + 1;

    for (int i = 0; i < daySpan; i++) {
      final date = DateTime(earliest.year, earliest.month, earliest.day + i);
      final key = '${date.year}-${date.month}-${date.day}';
      if (metDates.contains(key)) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }

    return best > currentStreak ? best : currentStreak;
  }

  // ── Reminder Notifications ───────────────────────────────────────────

  String _lastAlertShownDate = '';
  String get lastAlertShownDate => _lastAlertShownDate;

  bool get hasShownGoalAlertToday {
    final todayStr = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    return _lastAlertShownDate == todayStr;
  }

  Future<void> markGoalAlertShownToday() async {
    final todayStr = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    final previousValue = _lastAlertShownDate;
    _lastAlertShownDate = todayStr;
    notifyListeners();
    try {
      _lastError = null;
      final box = Hive.box('app_state');
      await box.put('water_goal_alert_shown_date', todayStr);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('water_goal_alert_shown_date', todayStr);
    } catch (e, st) {
      _lastAlertShownDate = previousValue;
      _lastError = 'Failed to mark water goal alert: $e';
      AppLogger.error('WaterProvider.markGoalAlertShownToday', e, st);
      notifyListeners();
    }
  }

  bool _remindersEnabled = false;
  bool get remindersEnabled => _remindersEnabled;

  int _reminderIntervalMinutes = 60;
  int get reminderIntervalMinutes => _reminderIntervalMinutes;

  int _reminderStartHour = 8;
  int get reminderStartHour => _reminderStartHour;

  int _reminderEndHour = 22;
  int get reminderEndHour => _reminderEndHour;

  /// Loads reminder preferences from Hive reminders_box box.
  void _loadReminderPreferencesCached() {
    try {
      final box = Hive.box<ReminderModel>('reminders_box');
      final reminder = box.get('water');
      if (reminder != null) {
        _remindersEnabled = reminder.isEnabled;
        if (reminder.reminderTimes.isNotEmpty) {
          _reminderStartHour = reminder.reminderTimes.first ~/ 60;
          _reminderEndHour = reminder.reminderTimes.last ~/ 60;
          if (reminder.reminderTimes.length > 1) {
            _reminderIntervalMinutes = reminder.reminderTimes[1] - reminder.reminderTimes[0];
          } else {
            _reminderIntervalMinutes = 60;
          }
        }
      } else {
        _lastAlertShownDate = sharedPrefs.getString('water_goal_alert_shown_date') ?? '';
      }
    } catch (e, st) {
      AppLogger.error('WaterProvider._loadReminderPreferencesCached', e, st);
    }
  }

  Future<AppPermissionStatus> setRemindersEnabled(bool enabled) async {
    final previousValue = _remindersEnabled;
    _remindersEnabled = enabled;
    notifyListeners(); // Instant UI update
    
    try {
      _lastError = null;
      final box = Hive.box<ReminderModel>('reminders_box');
      final reminder = box.get('water');
      if (reminder != null) {
        reminder.isEnabled = enabled;
        
        if (enabled) {
          final notifStatus = await NotificationService.instance.permissionService.requestNotificationPermission();
          if (notifStatus != AppPermissionStatus.granted) {
            _remindersEnabled = previousValue;
            reminder.isEnabled = previousValue;
            await box.put('water', reminder);
            notifyListeners();
            return notifStatus;
          }

          final exactStatus = await NotificationService.instance.permissionService.requestExactAlarmPermission();
          if (exactStatus != AppPermissionStatus.granted) {
            _remindersEnabled = previousValue;
            reminder.isEnabled = previousValue;
            await box.put('water', reminder);
            notifyListeners();
            return exactStatus;
          }
        }

        await box.put('water', reminder);
        
        final manager = NotificationManager();
        if (enabled) {
          await manager.scheduleWaterReminder(
            intervalMinutes: _reminderIntervalMinutes,
            startHour: _reminderStartHour,
            endHour: _reminderEndHour,
          );
        } else {
          await manager.cancelWaterReminders();
        }
      }
      return AppPermissionStatus.granted;
    } catch (e, st) {
      _remindersEnabled = previousValue;
      _lastError = 'Failed to update reminder status: $e';
      AppLogger.error('WaterProvider.setRemindersEnabled', e, st);
      notifyListeners();
      return AppPermissionStatus.denied;
    }
  }

  void setReminderInterval(int minutes) async {
    final previousValue = _reminderIntervalMinutes;
    _reminderIntervalMinutes = minutes;
    notifyListeners();
    
    try {
      _lastError = null;
      final box = Hive.box<ReminderModel>('reminders_box');
      final reminder = box.get('water');
      if (reminder != null) {
        final startM = _reminderStartHour * 60;
        var endM = _reminderEndHour * 60;
        if (endM <= startM) endM = startM + 120;
        final list = <int>[];
        for (var t = startM; t <= endM; t += minutes) {
          list.add(t);
        }
        reminder.reminderTimes = list;
        await box.put('water', reminder);
        
        final manager = NotificationManager();
        if (reminder.isEnabled) {
          await manager.scheduleWaterReminder(
            intervalMinutes: minutes,
            startHour: _reminderStartHour,
            endHour: _reminderEndHour,
          );
        }
      }
    } catch (e, st) {
      _reminderIntervalMinutes = previousValue;
      _lastError = 'Failed to update reminder interval: $e';
      AppLogger.error('WaterProvider.setReminderInterval', e, st);
      notifyListeners();
    }
  }

  void setReminderStartHour(int hour) async {
    _reminderStartHour = hour;
    notifyListeners();
    if (_remindersEnabled) setRemindersEnabled(true);
  }

  void setReminderEndHour(int hour) async {
    _reminderEndHour = hour;
    notifyListeners();
    if (_remindersEnabled) setRemindersEnabled(true);
  }

  Future<void> updateWaterGoal(double goalLiters) async {
    final profile = _profileDataSource.getProfile();
    if (profile != null) {
      profile.waterGoalLiters = goalLiters;
      await _profileDataSource.saveProfile(profile);
      _loadData();
    }
  }

  @override
  void dispose() {
    _remindersBoxSub?.cancel();
    super.dispose();
  }
}

/// Represents a single day's total intake.
class DailyIntake {
  final DateTime date;
  final int totalMl;
  const DailyIntake({required this.date, required this.totalMl});

  double get totalLiters => totalMl / 1000;
}
