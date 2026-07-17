import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../profile/data/profile_local_data_source.dart';
import '../../profile/data/profile_model.dart';
import '../../bmi/data/bmi_local_data_source.dart';
import '../../bmi/data/bmi_entry.dart';

import '../data/settings_model.dart';
import '../data/settings_repository.dart';
import '../domain/reminder_sync_service.dart';
import '../domain/data_backup_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  final ReminderSyncService _reminderSyncService = ReminderSyncService();
  final DataBackupService _dataBackupService = DataBackupService();

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
      await _reminderSyncService.toggleReminderBackground(
        type: 'water',
        val: true,
        masterNotificationsEnabled: true,
        profile: profile,
      );
    }
    if (_settings.bedtimeNotificationsEnabled) {
      await _reminderSyncService.toggleReminderBackground(
        type: 'bedtime',
        val: true,
        masterNotificationsEnabled: true,
        profile: profile,
      );
    }
    if (_settings.wakeupNotificationsEnabled) {
      await _reminderSyncService.toggleReminderBackground(
        type: 'wakeup',
        val: true,
        masterNotificationsEnabled: true,
        profile: profile,
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
      await _reminderSyncService.cancelAll();
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
    await _toggleReminderBackground(type, val);
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
    await _reminderSyncService.toggleReminderBackground(
      type: type,
      val: val,
      masterNotificationsEnabled: _settings.masterNotificationsEnabled,
      profile: getProfile(),
    );
  }

  Future<void> _syncAllRemindersWithManager() async {
    await _reminderSyncService.syncAllRemindersWithManager(
      settings: _settings,
      profile: getProfile(),
    );
  }

  // ── Data Backup & Management ──────────────────────────────────────────

  String exportDataAsJson() {
    return _dataBackupService.exportDataAsJson(
      profile: getProfile(),
      settings: _settings,
    );
  }

  Future<bool> importDataFromJson(String jsonString) async {
    final newSettings = await _dataBackupService.importDataFromJson(
      jsonString: jsonString,
      repository: _repository,
    );
    if (newSettings != null) {
      _settings = newSettings;
      await _syncAllRemindersWithManager();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> backupToFile() async {
    return await _dataBackupService.backupToFile(
      profile: getProfile(),
      settings: _settings,
    );
  }

  Future<bool> restoreFromFile() async {
    final newSettings = await _dataBackupService.restoreFromFile(
      repository: _repository,
    );
    if (newSettings != null) {
      _settings = newSettings;
      await _syncAllRemindersWithManager();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> clearAllData() async {
    await _reminderSyncService.cancelAll();
    _settings = await _dataBackupService.clearAllData(repository: _repository);
    notifyListeners();
  }
}
