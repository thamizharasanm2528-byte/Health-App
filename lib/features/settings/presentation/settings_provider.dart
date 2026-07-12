import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';

import '../../../core/services/notifications/notification_manager.dart';
import '../../../core/services/notifications/notification_service.dart';
import '../../../core/services/notifications/notification_constants.dart';
import '../../../core/services/notifications/notification_model.dart';

import '../../profile/data/profile_local_data_source.dart';
import '../../profile/data/profile_model.dart';
import '../../water/data/water_local_data_source.dart';
import '../../water/data/water_entry.dart';
import '../../steps/data/step_local_data_source.dart';
import '../../steps/data/step_entry.dart';
import '../../bmi/data/bmi_local_data_source.dart';
import '../../bmi/data/bmi_entry.dart';
import '../../sleep/data/sleep_local_data_source.dart';
import '../../sleep/data/sleep_record.dart';


import '../data/settings_model.dart';
import '../data/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  final NotificationManager _notificationManager = NotificationManager();

  SettingsProvider(this._repository) {
    _loadSettings();
  }

  late SettingsModel _settings;
  SettingsModel get settings => _settings;

  void _loadSettings() {
    _settings = _repository.getSettings();
  }

  // ── Theme scale ──
  double get textScaleFactor => 0.85; // Locked to small for the entire app

  Future<void> updateFontSize(String size) async {
    _settings.fontSize = size;
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  // ── Profile configuration ──
  ProfileModel getProfile() {
    final box = Hive.box<ProfileModel>(ProfileLocalDataSource.boxName);
    return box.get(0) ?? ProfileModel();
  }

  Future<void> updateProfile({
    required String name,
    required int age,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    DateTime? dateOfBirth,
  }) async {
    final box = Hive.box<ProfileModel>(ProfileLocalDataSource.boxName);
    final profile = getProfile();
    profile.name = name;
    profile.age = age;
    profile.heightCm = heightCm;
    profile.weightKg = weightKg;
    profile.activityLevel = activityLevel;
    if (dateOfBirth != null) {
      profile.dateOfBirth = dateOfBirth;
    }
    await box.put(0, profile);

    // Also update weight log in BMI history!
    final entry = BMIEntry.create(
      heightCm: heightCm,
      weightKg: weightKg,
      bmiValue: weightKg / ((heightCm / 100) * (heightCm / 100)),
      category: profile.bmiCategory,
    );
    await BmiLocalDataSource().saveBMIEntry(entry);

    notifyListeners();
  }

  Future<void> updateWeight(double weightKg) async {
    final box = Hive.box<ProfileModel>(ProfileLocalDataSource.boxName);
    final profile = getProfile();
    profile.weightKg = weightKg;
    await box.put(0, profile);

    final entry = BMIEntry.create(
      heightCm: profile.heightCm,
      weightKg: weightKg,
      bmiValue: weightKg / ((profile.heightCm / 100) * (profile.heightCm / 100)),
      category: profile.bmiCategory,
    );
    await BmiLocalDataSource().saveBMIEntry(entry);

    notifyListeners();
  }

  // ── Goals modification ──
  Future<void> updateGoals({
    required double waterGoalLiters,
    required int dailyStepGoal,
    required int sleepGoalMinutes,
  }) async {
    final box = Hive.box<ProfileModel>(ProfileLocalDataSource.boxName);
    final profile = getProfile();
    profile.waterGoalLiters = waterGoalLiters;
    profile.dailyStepGoal = dailyStepGoal;
    
    // We update target sleep based on bedtime / wake-up
    profile.wakeTimeMinutes = profile.bedtimeMinutes + sleepGoalMinutes;
    if (profile.wakeTimeMinutes >= 1440) {
      profile.wakeTimeMinutes -= 1440;
    }
    
    await box.put(0, profile);
    
    // Refresh notifications for water and sleep automatically to reflect new goals!
    if (_settings.waterNotificationsEnabled) {
      await _notificationManager.scheduleWaterReminder(
        intervalMinutes: 60,
        startHour: 8,
        endHour: 22,
      );
    }
    if (_settings.bedtimeNotificationsEnabled) {
      final bedtimeHour = profile.bedtimeMinutes ~/ 60;
      final bedtimeMin = profile.bedtimeMinutes % 60;
      await _notificationManager.scheduleSleepReminder(
        hour: bedtimeHour,
        minute: bedtimeMin,
        offsetMinutes: 30,
      );
    }
    if (_settings.wakeupNotificationsEnabled) {
      final wakeHour = profile.wakeTimeMinutes ~/ 60;
      final wakeMin = profile.wakeTimeMinutes % 60;
      await _notificationManager.scheduleWakeUpReminder(
        hour: wakeHour,
        minute: wakeMin,
      );
    }

    notifyListeners();
  }

  // ── Notifications configuration ──
  Future<void> setMasterNotificationsEnabled(bool val) async {
    _settings.masterNotificationsEnabled = val;
    notifyListeners(); // Instant UI update
    
    await _repository.saveSettings(_settings);
    if (val) {
      // Re-schedule everything that is enabled
      await _syncAllRemindersWithManager();
    } else {
      // Cancel everything in the manager
      await _notificationManager.cancelAll();
    }
  }

  Future<void> toggleReminder(String type, bool val) async {
    await toggleNotificationField(type, val);
  }

  Future<void> toggleNotificationField(String type, bool val) async {
    switch (type) {
      case 'water':
        _settings.waterNotificationsEnabled = val;
        break;
      case 'food':
        _settings.foodNotificationsEnabled = val;
        break;
      case 'bedtime':
        _settings.bedtimeNotificationsEnabled = val;
        break;
      case 'wakeup':
        _settings.wakeupNotificationsEnabled = val;
        break;
      case 'report':
        _settings.reportNotificationsEnabled = val;
        break;
    }
    notifyListeners(); // Instant UI update

    await _repository.saveSettings(_settings);
    _toggleReminderBackground(type, val);
  }

  Future<void> toggleVibrationField(String type, bool val) async {
    switch (type) {
      case 'water':
        _settings.waterVibrationEnabled = val;
        break;
      case 'food':
        _settings.foodVibrationEnabled = val;
        break;
      case 'bedtime':
        _settings.bedtimeVibrationEnabled = val;
        break;
      case 'wakeup':
        _settings.wakeupVibrationEnabled = val;
        break;
    }
    notifyListeners(); // Instant UI update

    await _repository.saveSettings(_settings);
    if (_settings.masterNotificationsEnabled) {
      await _syncAllRemindersWithManager();
    }
  }

  Future<void> toggleSoundField(String type, bool val) async {
    switch (type) {
      case 'water':
        _settings.waterSoundEnabled = val;
        break;
      case 'food':
        _settings.foodSoundEnabled = val;
        break;
      case 'bedtime':
        _settings.bedtimeSoundEnabled = val;
        break;
      case 'wakeup':
        _settings.wakeupSoundEnabled = val;
        break;
    }
    notifyListeners(); // Instant UI update

    await _repository.saveSettings(_settings);
    if (_settings.masterNotificationsEnabled) {
      await _syncAllRemindersWithManager();
    }
  }

  Future<void> _toggleReminderBackground(String type, bool val) async {
    switch (type) {
      case 'water':
        if (val && _settings.masterNotificationsEnabled) {
          await _notificationManager.scheduleWaterReminder(intervalMinutes: 60, startHour: 8, endHour: 22);
        } else {
          await _notificationManager.cancelWaterReminders();
        }
        break;

      case 'bedtime':
        if (val && _settings.masterNotificationsEnabled) {
          final p = getProfile();
          await _notificationManager.scheduleSleepReminder(
            hour: p.bedtimeMinutes ~/ 60,
            minute: p.bedtimeMinutes % 60,
            offsetMinutes: 30,
          );
        } else {
          await _notificationManager.cancelSleepReminders();
        }
        break;
      case 'wakeup':
        if (val && _settings.masterNotificationsEnabled) {
          final p = getProfile();
          await _notificationManager.scheduleWakeUpReminder(
            hour: p.wakeTimeMinutes ~/ 60,
            minute: p.wakeTimeMinutes % 60,
          );
        } else {
          await _notificationManager.cancelWakeUpReminders();
        }
        break;
      case 'report':
        if (val && _settings.masterNotificationsEnabled) {
          const androidDetails = AndroidNotificationDetails(
            NotificationConstants.channelGeneralId,
            NotificationConstants.channelGeneralName,
            channelDescription: NotificationConstants.channelGeneralDesc,
            importance: Importance.high,
            priority: Priority.high,
          );
          await NotificationService.instance.scheduler.scheduleWeekly(
            id: 9999,
            title: '📈 Weekly Health Report!',
            body: 'Check out your hydration, sleep consistency, and progress rates.',
            weekday: 7, // Sunday
            hour: 9,
            minute: 0,
            details: const NotificationDetails(android: androidDetails),
          );
        } else {
          await _notificationManager.cancelReminder(9999);
        }
        break;
    }
  }

  Future<void> _syncAllRemindersWithManager() async {
    final p = getProfile();
    if (_settings.waterNotificationsEnabled) {
      await _notificationManager.scheduleWaterReminder(intervalMinutes: 60, startHour: 8, endHour: 22);
    }
    if (_settings.bedtimeNotificationsEnabled) {
      await _notificationManager.scheduleSleepReminder(
        hour: p.bedtimeMinutes ~/ 60,
        minute: p.bedtimeMinutes % 60,
        offsetMinutes: 30,
      );
    }
    if (_settings.wakeupNotificationsEnabled) {
      await _notificationManager.scheduleWakeUpReminder(
        hour: p.wakeTimeMinutes ~/ 60,
        minute: p.wakeTimeMinutes % 60,
      );
    }

  }

  // ── Data Backup & Management ──────────────────────────────────────────

  String exportDataAsJson() {
    final export = <String, dynamic>{};

    final profile = getProfile();
    export['profile'] = {
      'name': profile.name,
      'age': profile.age,
      'heightCm': profile.heightCm,
      'weightKg': profile.weightKg,
      'targetWeightKg': profile.targetWeightKg,
      'activityLevel': profile.activityLevel,
      'waterGoalLiters': profile.waterGoalLiters,
      'dailyStepGoal': profile.dailyStepGoal,
      'bedtimeMinutes': profile.bedtimeMinutes,
      'wakeTimeMinutes': profile.wakeTimeMinutes,
      'foodPreferences': profile.foodPreferences,
    };

    export['settings'] = {
      'themeMode': _settings.themeMode,
      'fontSize': _settings.fontSize,
      'weightUnit': _settings.weightUnit,
      'heightUnit': _settings.heightUnit,
      'waterUnit': _settings.waterUnit,
      'masterNotificationsEnabled': _settings.masterNotificationsEnabled,
      'waterNotificationsEnabled': _settings.waterNotificationsEnabled,
      'foodNotificationsEnabled': _settings.foodNotificationsEnabled,
      'bedtimeNotificationsEnabled': _settings.bedtimeNotificationsEnabled,
      'wakeupNotificationsEnabled': _settings.wakeupNotificationsEnabled,
      'reportNotificationsEnabled': _settings.reportNotificationsEnabled,
    };

    final waterBox = Hive.box<WaterEntry>(WaterLocalDataSource.boxName);
    export['water_entries'] = waterBox.values.map((w) => {
      'id': w.id,
      'amountMl': w.amountMl,
      'timestamp': w.timestamp.toIso8601String(),
    }).toList();

    final stepBox = Hive.box<StepEntry>(StepLocalDataSource.boxName);
    export['step_entries'] = stepBox.values.map((s) => {
      'id': s.id,
      'steps': s.steps,
      'goal': s.goal,
      'date': s.date.toIso8601String(),
      'isSynced': s.isSynced,
    }).toList();

    final bmiBox = Hive.box<BMIEntry>(BmiLocalDataSource.boxName);
    export['bmi_entries'] = bmiBox.values.map((b) => {
      'id': b.id,
      'heightCm': b.heightCm,
      'weightKg': b.weightKg,
      'bmiValue': b.bmiValue,
      'category': b.category,
      'timestamp': b.timestamp.toIso8601String(),
    }).toList();

    final sleepBox = Hive.box<SleepRecord>(SleepLocalDataSource.boxName);
    export['sleep_records'] = sleepBox.values.map((sl) => {
      'id': sl.id,
      'bedtime': sl.bedtime.toIso8601String(),
      'wakeTime': sl.wakeTime.toIso8601String(),
      'durationHours': sl.durationHours,
      'status': sl.status,
    }).toList();



    return const JsonEncoder.withIndent('  ').convert(export);
  }

  Future<bool> importDataFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data.containsKey('profile')) {
        final profileBox = Hive.box<ProfileModel>(ProfileLocalDataSource.boxName);
        final map = data['profile'] as Map<String, dynamic>;
        final profile = ProfileModel(
          name: map['name'] as String? ?? '',
          age: map['age'] as int? ?? 25,
          heightCm: (map['heightCm'] as num?)?.toDouble() ?? 170.0,
          weightKg: (map['weightKg'] as num?)?.toDouble() ?? 70.0,
          targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble() ?? 70.0,
          activityLevel: map['activityLevel'] as String? ?? 'Moderately Active',
          waterGoalLiters: (map['waterGoalLiters'] as num?)?.toDouble() ?? 3.0,
          dailyStepGoal: map['dailyStepGoal'] as int? ?? 8000,
          bedtimeMinutes: map['bedtimeMinutes'] as int? ?? 1350,
          wakeTimeMinutes: map['wakeTimeMinutes'] as int? ?? 390,
          foodPreferences: List<String>.from(map['foodPreferences'] as List? ?? []),
        );
        await profileBox.put(0, profile);
      }

      if (data.containsKey('settings')) {
        final map = data['settings'] as Map<String, dynamic>;
        _settings = SettingsModel(
          themeMode: map['themeMode'] as String? ?? 'system',
          fontSize: map['fontSize'] as String? ?? 'medium',
          weightUnit: map['weightUnit'] as String? ?? 'kg',
          heightUnit: map['heightUnit'] as String? ?? 'cm',
          waterUnit: map['waterUnit'] as String? ?? 'ml',
          masterNotificationsEnabled: map['masterNotificationsEnabled'] as bool? ?? true,
          waterNotificationsEnabled: map['waterNotificationsEnabled'] as bool? ?? true,
          foodNotificationsEnabled: map['foodNotificationsEnabled'] as bool? ?? true,
          bedtimeNotificationsEnabled: map['bedtimeNotificationsEnabled'] as bool? ?? true,
          wakeupNotificationsEnabled: map['wakeupNotificationsEnabled'] as bool? ?? true,
          reportNotificationsEnabled: map['reportNotificationsEnabled'] as bool? ?? true,
        );
        await _repository.saveSettings(_settings);
      }

      if (data.containsKey('water_entries')) {
        final waterBox = Hive.box<WaterEntry>(WaterLocalDataSource.boxName);
        await waterBox.clear();
        for (final item in data['water_entries'] as List) {
          final map = item as Map<String, dynamic>;
          final entry = WaterEntry(
            id: map['id'] as String,
            amountMl: map['amountMl'] as int,
            timestamp: DateTime.parse(map['timestamp'] as String),
          );
          await waterBox.put(entry.id, entry);
        }
      }

      if (data.containsKey('step_entries')) {
        final stepBox = Hive.box<StepEntry>(StepLocalDataSource.boxName);
        await stepBox.clear();
        for (final item in data['step_entries'] as List) {
          final map = item as Map<String, dynamic>;
          final entry = StepEntry(
            id: map['id'] as String,
            steps: map['steps'] as int,
            goal: map['goal'] as int? ?? 8000,
            date: DateTime.parse(map['date'] as String),
            isSynced: map['isSynced'] as bool? ?? false,
          );
          await stepBox.put(entry.id, entry);
        }
      }

      if (data.containsKey('bmi_entries')) {
        final bmiBox = Hive.box<BMIEntry>(BmiLocalDataSource.boxName);
        await bmiBox.clear();
        for (final item in data['bmi_entries'] as List) {
          final map = item as Map<String, dynamic>;
          final entry = BMIEntry(
            id: map['id'] as String,
            heightCm: (map['heightCm'] as num).toDouble(),
            weightKg: (map['weightKg'] as num).toDouble(),
            bmiValue: (map['bmiValue'] as num).toDouble(),
            category: map['category'] as String,
            timestamp: DateTime.parse(map['timestamp'] as String),
          );
          await bmiBox.put(entry.id, entry);
        }
      }

      if (data.containsKey('sleep_records')) {
        final sleepBox = Hive.box<SleepRecord>(SleepLocalDataSource.boxName);
        await sleepBox.clear();
        for (final item in data['sleep_records'] as List) {
          final map = item as Map<String, dynamic>;
          final entry = SleepRecord(
            id: map['id'] as String,
            bedtime: DateTime.parse(map['bedtime'] as String),
            wakeTime: DateTime.parse(map['wakeTime'] as String),
            durationHours: (map['durationHours'] as num).toDouble(),
            status: map['status'] as String,
          );
          await sleepBox.put(entry.id, entry);
        }
      }



      await _syncAllRemindersWithManager();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> backupToFile() async {
    try {
      final jsonStr = exportDataAsJson();
      if (kIsWeb) {
        await Clipboard.setData(ClipboardData(text: jsonStr));
        return true;
      }
      final file = File('health_companion_backup.json');
      await file.writeAsString(jsonStr);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> restoreFromFile() async {
    try {
      if (kIsWeb) return false;
      final file = File('health_companion_backup.json');
      if (!await file.exists()) return false;
      final jsonStr = await file.readAsString();
      return await importDataFromJson(jsonStr);
    } catch (_) {
      return false;
    }
  }

  Future<void> clearAllData() async {
    await Hive.box<ProfileModel>(ProfileLocalDataSource.boxName).clear();
    await Hive.box<WaterEntry>(WaterLocalDataSource.boxName).clear();
    await Hive.box<StepEntry>(StepLocalDataSource.boxName).clear();
    await Hive.box<BMIEntry>(BmiLocalDataSource.boxName).clear();
    await Hive.box<SleepRecord>(SleepLocalDataSource.boxName).clear();
    await Hive.box<NotificationModel>(NotificationService.boxName).clear();

    
    await _notificationManager.cancelAll();
    
    _settings = SettingsModel();
    await _repository.saveSettings(_settings);

    notifyListeners();
  }
}
