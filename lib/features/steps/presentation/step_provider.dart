import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../profile/data/profile_local_data_source.dart';
import '../data/health_service.dart';
import '../data/step_entry.dart';
import '../domain/step_repository.dart';

/// Provider managing step tracking state, sync options, streaks, and statistics.
class StepProvider extends ChangeNotifier with WidgetsBindingObserver {
  final StepRepository _repository;
  final ProfileLocalDataSource _profileDataSource;
  final HealthService _healthService;

  StepProvider(this._repository, this._profileDataSource, this._healthService) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        print('StepProvider: App returned to foreground. Syncing steps.');
      }
      syncSteps();
    }
  }

  // ── State Variables ──────────────────────────────────────────────────

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StepEntry? _todayEntry;
  StepEntry? get todayEntry => _todayEntry;

  List<StepEntry> _historyEntries = [];
  List<StepEntry> get historyEntries => List.unmodifiable(_historyEntries);

  // Health Connect SDK states
  HealthConnectSdkStatus? _connectStatus = HealthConnectSdkStatus.sdkAvailable;
  HealthConnectSdkStatus? get connectStatus => _connectStatus;

  bool _isConnectSupported = true;
  bool get isConnectSupported => _isConnectSupported;

  bool _hasConnectPermissions = false;
  bool get hasConnectPermissions => _hasConnectPermissions;

  bool _isPermissionsPermanentlyDenied = false;
  bool get isPermissionsPermanentlyDenied => _isPermissionsPermanentlyDenied;

  Future<void> _init() async {
    // Load cached data immediately for instant UI render
    _loadData();
    
    await checkConnectStatus();
    
    // Defer heavy Health Connect sync to after first frame renders
    if (_hasConnectPermissions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        syncSteps();
      });
    }
  }

  /// Check Health Connect installation and permission state
  Future<void> checkConnectStatus() async {
    _isConnectSupported = await _healthService.isSupported();
    if (Platform.isAndroid) {
      _connectStatus = await _healthService.getHealthConnectStatus();
    }
    _hasConnectPermissions = await _healthService.hasPermissions();
    if (_hasConnectPermissions) {
      _isPermissionsPermanentlyDenied = false;
    }
    notifyListeners();
  }

  /// Reload step data from Hive box.
  void _loadData() {
    final todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _todayEntry = _repository.getStepEntry(todayId);

    // If today has no entry, create a default baseline entry
    _todayEntry ??= StepEntry(
      id: todayId,
      steps: 0,
      goal: currentGoal,
      date: DateTime.now(),
      isSynced: false,
    );

    _historyEntries = _repository.getAllEntries();
    notifyListeners();
  }

  /// Reload helper.
  void refresh() => _loadData();

  // ── Goal Management ──────────────────────────────────────────────────

  /// Standard daily goal loaded from user profile.
  int get currentGoal {
    final profile = _profileDataSource.getProfile();
    return profile?.dailyStepGoal ?? 8000;
  }

  /// Updates the step goal in the profile and saves it.
  Future<void> updateGoal(int newGoal) async {
    final profile = _profileDataSource.getProfile();
    if (profile != null) {
      profile.dailyStepGoal = newGoal;
      await _profileDataSource.saveProfile(profile);
    }

    // Update today's goal as well
    if (_todayEntry != null) {
      _todayEntry!.goal = newGoal;
      await _repository.saveStepEntry(_todayEntry!);
    }

    _loadData();
  }



  // ── Sync with Health Connect / Apple Health ──────────────────────────

  /// Pull steps from Apple HealthKit / Google Health Connect for today & past 30 days.
  Future<bool> syncSteps() async {
    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await checkConnectStatus();

      // Check SDK availability on Android
      if (Platform.isAndroid) {
        if (_connectStatus == HealthConnectSdkStatus.sdkUnavailable) {
          _errorMessage = 'Health Connect is not installed on this device.';
          _isSyncing = false;
          notifyListeners();
          return false;
        }
        if (_connectStatus == HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
          _errorMessage = 'Health Connect requires an update in the Play Store.';
          _isSyncing = false;
          notifyListeners();
          return false;
        }
      }

      // Check support
      if (!_isConnectSupported) {
        _errorMessage = 'Health tracking integration is not supported on this device.';
        _isSyncing = false;
        notifyListeners();
        return false;
      }

      // Verify or request permissions
      if (!_hasConnectPermissions) {
        final request = await _healthService.requestPermissions();
        if (!request) {
          if (Platform.isAndroid) {
            final permanentlyDenied = await Permission.activityRecognition.isPermanentlyDenied;
            if (permanentlyDenied) {
              _isPermissionsPermanentlyDenied = true;
            }
          }
          _errorMessage = 'Health data permissions denied. Please enable sync in app settings.';
          _hasConnectPermissions = false;
          _isSyncing = false;
          notifyListeners();
          return false;
        }
      }

      // If we reach here, we have permissions
      _hasConnectPermissions = true;
      _isPermissionsPermanentlyDenied = false;

      final now = DateTime.now();

      // Sync past 30 days
      for (int i = 0; i < 30; i++) {
        final date = DateTime(now.year, now.month, now.day - i);
        final id = DateFormat('yyyy-MM-dd').format(date);
        final start = DateTime(date.year, date.month, date.day);
        final end = i == 0 ? now : DateTime(date.year, date.month, date.day, 23, 59, 59);

        final steps = await _healthService.fetchSteps(start, end);
        if (steps != null) {
          final existing = _repository.getStepEntry(id);
          final entry = StepEntry(
            id: id,
            steps: steps,
            goal: existing?.goal ?? currentGoal,
            date: date,
            isSynced: true,
          );
          await _repository.saveStepEntry(entry);
        }
      }

      _loadData();
      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Sync failed: ${e.toString()}';
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  // ── Streaks ──────────────────────────────────────────────────────────

  int get currentStreak {
    int streak = 0;
    final today = DateTime.now();

    for (int i = 1; i <= 365; i++) {
      final date = DateTime(today.year, today.month, today.day - i);
      final id = DateFormat('yyyy-MM-dd').format(date);
      final entry = _repository.getStepEntry(id);

      if (entry != null && entry.isGoalAchieved) {
        streak++;
      } else {
        break;
      }
    }

    if (_todayEntry != null && _todayEntry!.isGoalAchieved) {
      streak++;
    }

    return streak;
  }

  int get bestStreak {
    final entries = _repository.getAllEntries();
    if (entries.isEmpty) return currentStreak;

    final sorted = List<StepEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    int best = 0;
    int current = 0;
    DateTime? prevDate;

    for (final entry in sorted) {
      if (entry.isGoalAchieved) {
        if (prevDate == null) {
          current = 1;
        } else {
          final difference = entry.date.difference(prevDate).inDays;
          if (difference == 1) {
            current++;
          } else if (difference > 1) {
            current = 1;
          }
        }
        if (current > best) best = current;
        prevDate = entry.date;
      } else {
        current = 0;
        prevDate = null;
      }
    }

    return best > currentStreak ? best : currentStreak;
  }

  // ── Statistics & Analytics ───────────────────────────────────────────

  List<StepEntry> getRangeEntries(int numDays) {
    final now = DateTime.now();
    return List.generate(numDays, (i) {
      final date = DateTime(now.year, now.month, now.day - (numDays - 1 - i));
      final id = DateFormat('yyyy-MM-dd').format(date);
      var entry = _repository.getStepEntry(id);
      
      entry ??= StepEntry(
        id: id,
        steps: 0,
        goal: currentGoal,
        date: date,
        isSynced: false,
      );
      return entry;
    });
  }

  StepStats calculateStats(List<StepEntry> entries) {
    if (entries.isEmpty) return StepStats.empty();

    int totalSteps = 0;
    int maxSteps = 0;
    int minSteps = 99999999;
    int daysAchievedGoal = 0;

    for (final entry in entries) {
      totalSteps += entry.steps;
      if (entry.steps > maxSteps) maxSteps = entry.steps;
      if (entry.steps > 0 && entry.steps < minSteps) minSteps = entry.steps;
      if (entry.isGoalAchieved) daysAchievedGoal++;
    }

    final activeDays = entries.where((e) => e.steps > 0).length;
    final average = activeDays > 0 ? (totalSteps / activeDays).round() : 0;
    final achievementRate = (daysAchievedGoal / entries.length) * 100;

    return StepStats(
      averageSteps: average,
      highestSteps: maxSteps,
      lowestSteps: minSteps == 99999999 ? 0 : minSteps,
      achievementRatePercent: achievementRate.round(),
    );
  }
}

class StepStats {
  final int averageSteps;
  final int highestSteps;
  final int lowestSteps;
  final int achievementRatePercent;

  StepStats({
    required this.averageSteps,
    required this.highestSteps,
    required this.lowestSteps,
    required this.achievementRatePercent,
  });

  factory StepStats.empty() {
    return StepStats(
      averageSteps: 0,
      highestSteps: 0,
      lowestSteps: 0,
      achievementRatePercent: 0,
    );
  }
}
