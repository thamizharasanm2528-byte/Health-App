import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../profile/data/profile_local_data_source.dart';
import '../../profile/data/profile_model.dart';
import '../../steps/data/step_local_data_source.dart';
import '../../water/data/water_local_data_source.dart';
import '../../sleep/data/sleep_local_data_source.dart';
import '../../../core/services/notifications/notification_service.dart';
import '../../../core/services/notifications/notification_constants.dart';
import '../../../core/services/notifications/notification_model.dart';

/// State manager for the Dashboard screen.
///
/// Loads the user profile, calculates greetings, score, and aggregates daily stats
/// dynamically from water and steps local data sources.
class DashboardProvider extends ChangeNotifier {
  final ProfileLocalDataSource _profileDataSource;
  final WaterLocalDataSource _waterDataSource;
  final StepLocalDataSource _stepDataSource;
  final SleepLocalDataSource _sleepDataSource;

  DashboardProvider(
    this._profileDataSource,
    this._waterDataSource,
    this._stepDataSource,
    this._sleepDataSource,
  ) {
    _loadProfile();
  }

  // ── Profile ──────────────────────────────────────────────────────────

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  NotificationModel? _cachedNextNotification;
  NotificationModel? get cachedNextNotification => _cachedNextNotification;

  void _loadProfile() {
    _profile = _profileDataSource.getProfile();
    _updateCachedNextNotification();
  }

  void _updateCachedNextNotification() {
    _cachedNextNotification = _queryNextUpcomingNotification();
  }

  /// Reload profile (e.g. after editing in settings).
  void refreshProfile() {
    _loadProfile();
    notifyListeners();
  }

  /// Refresh all dashboard data.
  void refreshAll() {
    _loadProfile();
    notifyListeners();
  }

  // ── Greeting ─────────────────────────────────────────────────────────

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get userName => _profile?.name ?? 'User';

  String get formattedDate {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  // ── Bottom navigation ────────────────────────────────────────────────

  int _tabIndex = 0;
  int get tabIndex => _tabIndex;

  void setTabIndex(int index) {
    _tabIndex = index;
    if (index == 0) refreshAll(); // refresh dashboard on return
    notifyListeners();
  }

  // ── Health Score (computed from profile completeness + goals) ────────

  double get healthScore {
    if (_profile == null) return 0;
    double score = 0;

    // BMI factor (25 pts)
    final bmi = _profile!.bmi;
    if (bmi >= 18.5 && bmi < 25) {
      score += 25;
    } else if (bmi >= 16 && bmi < 30) {
      score += 15;
    } else {
      score += 5;
    }

    // Sleep factor (25 pts)
    final sleep = _profile!.sleepDurationHours;
    if (sleep >= 7 && sleep <= 9) {
      score += 25;
    } else if (sleep >= 6 && sleep <= 10) {
      score += 15;
    } else {
      score += 5;
    }

    // Activity factor (25 pts)
    switch (_profile!.activityLevel) {
      case 'Very Active':
        score += 25;
      case 'Moderately Active':
        score += 20;
      case 'Lightly Active':
        score += 12;
      default:
        score += 5;
    }
    return score * (100.0 / 75.0);
  }

  int get healthScorePercent => healthScore.round().clamp(0, 100);

  String get healthScoreMessage {
    final s = healthScorePercent;
    if (s >= 80) return 'Keep going! You\'re doing great.';
    if (s >= 60) return 'Good progress. Stay consistent!';
    if (s >= 40) return 'Room for improvement. You got this!';
    return 'Let\'s start building healthy habits!';
  }

  // ── Water (live from Hive) ───────────────────────────────────────────

  double get waterIntake => _waterDataSource.totalForDate(DateTime.now()) / 1000;
  double get waterGoal => _profile?.waterGoalLiters ?? 3.0;
  double get waterProgress => (waterIntake / waterGoal).clamp(0.0, 1.0);

  // ── Steps (live from Hive) ───────────────────────────────────────────

  int get todaySteps {
    final todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final entry = _stepDataSource.getStepEntry(todayId);
    return entry?.steps ?? 0;
  }

  int get stepGoal => _profile?.dailyStepGoal ?? 8000;
  double get stepProgress => (todaySteps / stepGoal).clamp(0.0, 1.0);

  // ── Sleep ────────────────────────────────────────────────────────────

  double get lastNightSleep {
    final records = _sleepDataSource.getAllRecords();
    if (records.isNotEmpty) {
      return records.first.durationHours;
    }
    return _profile?.sleepDurationHours ?? 8.0;
  }

  double get sleepTarget => _profile?.sleepDurationHours ?? 8.0;
  double get sleepProgress => (lastNightSleep / sleepTarget).clamp(0.0, 1.0);

  // ── BMI ──────────────────────────────────────────────────────────────

  double get currentBmi => _profile?.bmi ?? 0;
  String get bmiCategory => _profile?.bmiCategory ?? '--';
  double get recommendedBestWeight {
    if (_profile == null) return 70.0;
    final h = _profile!.heightCm / 100;
    return 21.7 * h * h;
  }

  double get targetWeight {
    if (_profile == null) return 70.0;
    return _profile!.targetWeightKg;
  }

  String get healthyWeightRange {
    if (_profile == null) return '--';
    final h = _profile!.heightCm / 100;
    final low = (18.5 * h * h).toStringAsFixed(0);
    final high = (24.9 * h * h).toStringAsFixed(0);
    return '$low–$high kg';
  }



  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayH = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayH.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  // ── Upcoming Notification getters ────────────────────────────────────

  NotificationModel? getNextUpcomingNotification() {
    return _cachedNextNotification;
  }

  NotificationModel? _queryNextUpcomingNotification() {
    final savedList = NotificationService.instance.getSavedMetadata();
    if (savedList.isEmpty) return null;

    final now = DateTime.now();
    final futureNotifications = <NotificationModel>[];

    for (final m in savedList) {
      if (!m.isEnabled) continue;
      final scheduled = m.scheduledDate;
      if (scheduled == null) continue;
      DateTime targetTime = scheduled;

      if (targetTime.isBefore(now)) {
        if (m.repeatType == NotificationConstants.repeatDaily) {
          targetTime = DateTime(now.year, now.month, now.day, targetTime.hour, targetTime.minute);
          if (targetTime.isBefore(now)) {
            targetTime = targetTime.add(const Duration(days: 1));
          }
        } else if (m.repeatType == NotificationConstants.repeatWeekly) {
          final originalDate = m.scheduledDate!;
          targetTime = DateTime(now.year, now.month, now.day, targetTime.hour, targetTime.minute);
          while (targetTime.weekday != originalDate.weekday || targetTime.isBefore(now)) {
            targetTime = targetTime.add(const Duration(days: 1));
          }
        }
      }
      
      m.scheduledDate = targetTime;
      futureNotifications.add(m);
    }

    if (futureNotifications.isEmpty) return null;

    futureNotifications.sort((a, b) => a.scheduledDate!.compareTo(b.scheduledDate!));
    return futureNotifications.first;
  }

  bool get hasUpcomingReminder => getNextUpcomingNotification() != null;

  String get nextReminderEmoji {
    final notif = getNextUpcomingNotification();
    if (notif == null) return '🔔';
    if (notif.notificationType == NotificationConstants.typeWater) return '💧';
    if (notif.notificationType == NotificationConstants.typeBedtime) return '🛌';
    if (notif.notificationType == NotificationConstants.typeWakeUp) return '🌅';
    return '🔔';
  }

  String get nextReminderTitle {
    final notif = getNextUpcomingNotification();
    if (notif == null) return 'No Reminders';
    return notif.title;
  }

  String get nextReminderTimeStr {
    final notif = getNextUpcomingNotification();
    if (notif == null || notif.scheduledDate == null) return '';
    return _formatTime(notif.scheduledDate!.hour, notif.scheduledDate!.minute);
  }
}
