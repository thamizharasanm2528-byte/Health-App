import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

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
import '../../../core/services/notifications/notification_service.dart';
import '../../../core/services/notifications/notification_model.dart';

import '../data/settings_model.dart';
import '../data/settings_repository.dart';

class DataBackupService {
  String exportDataAsJson({
    required ProfileModel profile,
    required SettingsModel settings,
  }) {
    final export = <String, dynamic>{};

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
      'themeMode': settings.themeMode,
      'fontSize': settings.fontSize,
      'weightUnit': settings.weightUnit,
      'heightUnit': settings.heightUnit,
      'waterUnit': settings.waterUnit,
      'masterNotificationsEnabled': settings.masterNotificationsEnabled,
      'waterNotificationsEnabled': settings.waterNotificationsEnabled,
      'foodNotificationsEnabled': settings.foodNotificationsEnabled,
      'bedtimeNotificationsEnabled': settings.bedtimeNotificationsEnabled,
      'wakeupNotificationsEnabled': settings.wakeupNotificationsEnabled,
      'reportNotificationsEnabled': settings.reportNotificationsEnabled,
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

  Future<SettingsModel?> importDataFromJson({
    required String jsonString,
    required SettingsRepository repository,
  }) async {
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

      SettingsModel? newSettings;
      if (data.containsKey('settings')) {
        final map = data['settings'] as Map<String, dynamic>;
        newSettings = SettingsModel(
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
        await repository.saveSettings(newSettings);
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

      return newSettings;
    } catch (_) {
      return null;
    }
  }

  Future<bool> backupToFile({
    required ProfileModel profile,
    required SettingsModel settings,
  }) async {
    try {
      final jsonStr = exportDataAsJson(profile: profile, settings: settings);
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

  Future<SettingsModel?> restoreFromFile({
    required SettingsRepository repository,
  }) async {
    try {
      if (kIsWeb) return null;
      final file = File('health_companion_backup.json');
      if (!await file.exists()) return null;
      final jsonStr = await file.readAsString();
      return await importDataFromJson(jsonString: jsonStr, repository: repository);
    } catch (_) {
      return null;
    }
  }

  Future<SettingsModel> clearAllData({
    required SettingsRepository repository,
  }) async {
    await Hive.box<ProfileModel>(ProfileLocalDataSource.boxName).clear();
    await Hive.box<WaterEntry>(WaterLocalDataSource.boxName).clear();
    await Hive.box<StepEntry>(StepLocalDataSource.boxName).clear();
    await Hive.box<BMIEntry>(BmiLocalDataSource.boxName).clear();
    await Hive.box<SleepRecord>(SleepLocalDataSource.boxName).clear();
    await Hive.box<NotificationModel>(NotificationService.boxName).clear();

    final newSettings = SettingsModel();
    await repository.saveSettings(newSettings);

    return newSettings;
  }
}
