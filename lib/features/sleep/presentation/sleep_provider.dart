import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import '../../../core/services/app_logger.dart';
import '../../profile/data/profile_local_data_source.dart';
import '../../profile/data/profile_model.dart';
import '../../reminders/data/reminder_model.dart';
import '../../alarm/data/alarm_settings_model.dart';
import '../data/sleep_record.dart';
import '../domain/sleep_repository.dart';

/// Provider managing target sleep times, actual sleep records logs,
/// weekly/monthly analytics, and local reminder notifications settings.
class SleepProvider extends ChangeNotifier {
  final SleepRepository _repository;
  final ProfileLocalDataSource _profileDataSource;

  StreamSubscription? _remindersBoxSub;
  StreamSubscription? _alarmSettingsBoxSub;

  SleepProvider(this._repository, this._profileDataSource) {
    _loadProfile();
    _loadRecords();

    try {
      _remindersBoxSub = Hive.box<ReminderModel>('reminders_box').watch().listen((_) {
        _loadProfile();
        notifyListeners();
      });
    } catch (e, st) {
      AppLogger.error('SleepProvider (reminders_box watch)', e, st);
    }

    try {
      _alarmSettingsBoxSub = Hive.box<AlarmSettingsModel>('alarm_settings_box').watch().listen((_) {
        _loadProfile();
        notifyListeners();
      });
    } catch (e, st) {
      AppLogger.error('SleepProvider (alarm_settings_box watch)', e, st);
    }
  }

  // ── Target Sleep & Profile state ──────────────────────────────────────

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  int _bedtimeMinutes = 1350; // 22:30
  int get bedtimeMinutes => _bedtimeMinutes;

  int _wakeTimeMinutes = 390; // 06:30
  int get wakeTimeMinutes => _wakeTimeMinutes;

  bool _hasWakeupAlarm = false;
  int get wakeMinutes => _wakeTimeMinutes; // (if needed by other code symbols)
  bool get hasWakeupAlarm => _hasWakeupAlarm;

  void _loadProfile() {
    _profile = _profileDataSource.getProfile();
    if (_profile != null) {
      _bedtimeMinutes = _profile!.bedtimeMinutes;
      _wakeTimeMinutes = _profile!.wakeTimeMinutes;
    }

    // Sync bedtime from bedtime reminder in reminders_box
    try {
      final box = Hive.box<ReminderModel>('reminders_box');
      final reminder = box.get('bedtime');
      if (reminder != null && reminder.reminderTimes.isNotEmpty) {
        _bedtimeMinutes = reminder.reminderTimes.first;
      }
    } catch (e, st) {
      AppLogger.error('SleepProvider._loadProfile (bedtime read)', e, st);
    }

    // Sync wakeup from primary active alarm in alarm_settings_box
    try {
      final box = Hive.box<AlarmSettingsModel>('alarm_settings_box');
      final alarms = box.values.toList();
      final enabledAlarms = alarms.where((a) => a.isEnabled).toList();
      if (enabledAlarms.isEmpty) {
        _hasWakeupAlarm = false;
      } else {
        final primary = enabledAlarms.firstWhere(
          (a) => a.isPrimaryWakeup,
          orElse: () => enabledAlarms.first,
        );
        _wakeTimeMinutes = primary.hour * 60 + primary.minute;
        _hasWakeupAlarm = true;
      }
    } catch (_) {
      _hasWakeupAlarm = false;
    }
  }

  void refreshAll() {
    _loadProfile();
    _loadRecords();
    notifyListeners();
  }

  /// Calculates expected sleep duration in hours.
  double get expectedSleepDurationHours {
    if (!_hasWakeupAlarm) return 0.0;
    var diff = _wakeTimeMinutes - _bedtimeMinutes;
    if (diff <= 0) diff += 1440; // crosses midnight
    return diff / 60;
  }

  /// Human-readable expected bedtime.
  String get bedtimeFormatted => _formatMinutes(_bedtimeMinutes);

  /// Human-readable expected wake time.
  String get wakeTimeFormatted => _hasWakeupAlarm ? _formatMinutes(_wakeTimeMinutes) : 'No Wake-up Alarm Set';

  String _formatMinutes(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${displayH.toString()}:${m.toString().padLeft(2, '0')} $period';
  }

  /// Updates the target bedtime.
  Future<void> updateTargetBedtime(int minutes) async {
    _bedtimeMinutes = minutes;
    if (_profile != null) {
      _profile!.bedtimeMinutes = minutes;
      await _profileDataSource.saveProfile(_profile!);
    }
    notifyListeners();
  }

  /// Updates the target wake-up time.
  Future<void> updateTargetWakeTime(int minutes) async {
    _wakeTimeMinutes = minutes;
    if (_profile != null) {
      _profile!.wakeTimeMinutes = minutes;
      await _profileDataSource.saveProfile(_profile!);
    }
    notifyListeners();
  }

  // ── Sleep Quality Status Helper ──────────────────────────────────────

  /// Categorizes sleep quality status by hours duration.
  String getSleepStatus(double hours) {
    if (hours >= 7.0 && hours <= 9.0) return 'Excellent';
    if ((hours >= 6.0 && hours < 7.0) || (hours > 9.0 && hours <= 10.0)) return 'Good';
    return 'Needs Improvement';
  }

  // ── Sleep Logging History ───────────────────────────────────────────

  List<SleepRecord> _history = [];
  List<SleepRecord> get history => _history;

  void _loadRecords() {
    _history = _repository.getAllRecords();
  }

  /// Saves a new sleep session log.
  Future<void> logSleep({
    required DateTime bedtime,
    required DateTime wakeTime,
  }) async {
    var diff = wakeTime.difference(bedtime).inMinutes;
    if (diff <= 0) diff += 1440; // backup crossover

    final durationHours = diff / 60.0;
    final status = getSleepStatus(durationHours);

    final record = SleepRecord.create(
      bedtime: bedtime,
      wakeTime: wakeTime,
      durationHours: durationHours,
      status: status,
    );

    await _repository.saveSleepRecord(record);
    _loadRecords();
    notifyListeners();
  }

  /// Logs sleep automatically from the wake-up alarm dismissal.
  Future<void> logSleepFromAlarmDismissal() async {
    final now = DateTime.now();
    final wakeTime = now;
    var bedtime = DateTime(now.year, now.month, now.day, _bedtimeMinutes ~/ 60, _bedtimeMinutes % 60);
    if (bedtime.isAfter(wakeTime)) {
      bedtime = bedtime.subtract(const Duration(days: 1));
    }
    
    // Check if a sleep record already exists for today to avoid duplicates
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final alreadyLogged = _history.any((r) => DateFormat('yyyy-MM-dd').format(r.wakeTime) == todayStr);
    if (alreadyLogged) {
      return;
    }

    await logSleep(bedtime: bedtime, wakeTime: wakeTime);
  }

  /// Deletes a logged record by ID.
  Future<void> deleteSleepRecord(String id) async {
    await _repository.deleteSleepRecord(id);
    _loadRecords();
    notifyListeners();
  }

  // ── Sleep Statistics & Consistency ────────────────────────────────────

  /// Calculates statistics for a given range of sleep logs.
  SleepStats calculateStats(List<SleepRecord> records) {
    if (records.isEmpty) return SleepStats.empty();

    double totalHours = 0.0;
    double maxHours = 0.0;
    double minHours = 24.0;
    int goalMetDays = 0;

    for (final rec in records) {
      totalHours += rec.durationHours;
      if (rec.durationHours > maxHours) maxHours = rec.durationHours;
      if (rec.durationHours < minHours) minHours = rec.durationHours;
      
      // Goal achieved if duration is between 7 and 9 hours
      if (rec.durationHours >= 7.0 && rec.durationHours <= 9.0) {
        goalMetDays++;
      }
    }

    final average = totalHours / records.length;
    final goalPercent = (goalMetDays / records.length) * 100;

    return SleepStats(
      averageHours: average,
      longestHours: maxHours,
      shortestHours: minHours == 24.0 ? 0.0 : minHours,
      goalAchievementPercent: goalPercent.round(),
    );
  }

  /// Filters logs range entries.
  List<SleepRecord> getRangeEntries(int numDays) {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: numDays));
    return _history.where((r) => r.bedtime.isAfter(cutoff)).toList().reversed.toList();
  }

  /// Returns sleep consistency score out of 100 based on standard deviation of sleep bedtime.
  int get sleepConsistencyScore {
    if (_history.length < 2) return 100; // Perfect base

    // Calculate variance of bedtime minutes since midnight
    double sum = 0.0;
    final bedtimeMins = _history.take(7).map((r) {
      return r.bedtime.hour * 60 + r.bedtime.minute;
    }).toList();

    final mean = bedtimeMins.reduce((a, b) => a + b) / bedtimeMins.length;
    for (final val in bedtimeMins) {
      sum += (val - mean) * (val - mean);
    }
    final variance = sum / bedtimeMins.length;
    
    // Normal deviation limit: higher variance drops consistency
    // e.g. dev of 30 mins (variance = 900) maps to ~90 consistency
    final consistency = (100 - (variance / 150)).round();
    return consistency.clamp(30, 100);
  }
}

/// Statistics helper summary.
class SleepStats {
  final double averageHours;
  final double longestHours;
  final double shortestHours;
  final int goalAchievementPercent;

  SleepStats({
    required this.averageHours,
    required this.longestHours,
    required this.shortestHours,
    required this.goalAchievementPercent,
  });

  factory SleepStats.empty() {
    return SleepStats(
      averageHours: 0.0,
      longestHours: 0.0,
      shortestHours: 0.0,
      goalAchievementPercent: 0,
    );
  }
}
