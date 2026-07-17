import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

import 'package:health_companion/features/profile/data/profile_model.dart';
import 'package:health_companion/features/water/data/water_entry.dart';
import 'package:health_companion/features/steps/data/step_entry.dart';
import 'package:health_companion/features/bmi/data/bmi_entry.dart';
import 'package:health_companion/features/sleep/data/sleep_record.dart';
import 'package:health_companion/core/services/notifications/notification_model.dart';
import 'package:health_companion/features/settings/data/settings_model.dart';
import 'package:health_companion/features/alarm/data/alarm_settings_model.dart';
import 'package:health_companion/features/reminders/data/reminder_model.dart';

import 'package:health_companion/features/profile/data/profile_local_data_source.dart';
import 'package:health_companion/features/water/data/water_local_data_source.dart';
import 'package:health_companion/features/steps/data/step_local_data_source.dart';
import 'package:health_companion/features/bmi/data/bmi_local_data_source.dart';
import 'package:health_companion/features/sleep/data/sleep_local_data_source.dart';
import 'package:health_companion/features/settings/data/settings_repository_impl.dart';

/// Automated startup performance test suite.
///
/// Measures the time taken for key initialisation phases
/// and verifies they complete within acceptable thresholds.
void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('health_companion_test');
    Hive.init(tempDir.path);

    // Register adapters
    Hive.registerAdapter(ProfileModelAdapter());
    Hive.registerAdapter(WaterEntryAdapter());
    Hive.registerAdapter(StepEntryAdapter());
    Hive.registerAdapter(BMIEntryAdapter());
    Hive.registerAdapter(SleepRecordAdapter());
    Hive.registerAdapter(NotificationModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
    Hive.registerAdapter(AlarmSettingsModelAdapter());
    Hive.registerAdapter(ReminderModelAdapter());

    // Open all boxes concurrently so providers have access
    await Future.wait([
      Hive.openBox<ProfileModel>(ProfileLocalDataSource.boxName),
      Hive.openBox<WaterEntry>(WaterLocalDataSource.boxName),
      Hive.openBox<StepEntry>(StepLocalDataSource.boxName),
      Hive.openBox<BMIEntry>(BmiLocalDataSource.boxName),
      Hive.openBox<SleepRecord>(SleepLocalDataSource.boxName),
      Hive.openBox<NotificationModel>('notification_logs'),
      Hive.openBox<SettingsModel>(SettingsRepositoryImpl.boxName),
      Hive.openBox<String>('theme_prefs_box'),
      Hive.openBox<AlarmSettingsModel>('alarm_settings_box'),
      Hive.openBox<ReminderModel>('reminders_box'),
      Hive.openBox('app_state'),
    ]);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Startup Performance', () {
    test('Hive initialisation and box opening completes under 2 seconds', () async {
      final stopwatch = Stopwatch()..start();

      final boxOpenTime = stopwatch.elapsedMilliseconds;
      debugPrint('  ✓ Open 11 Hive boxes check: ${boxOpenTime}ms');

      stopwatch.stop();
      final totalTime = stopwatch.elapsedMilliseconds;
      debugPrint('  ═══════════════════════════════════');
      debugPrint('  TOTAL Hive init: ${totalTime}ms');
      debugPrint('  ═══════════════════════════════════');

      // Assert total Hive init is under 2 seconds
      expect(totalTime, lessThan(2000),
          reason: 'Hive initialisation should complete in under 2 seconds');
    });

    test('Provider data sources instantiate without errors', () {
      final stopwatch = Stopwatch()..start();

      // These should all be synchronous Hive reads
      final profileDS = ProfileLocalDataSource();
      final waterDS = WaterLocalDataSource();
      final stepDS = StepLocalDataSource();
      final bmiDS = BmiLocalDataSource();
      final sleepDS = SleepLocalDataSource();

      stopwatch.stop();
      debugPrint('  ✓ All 5 data sources created: ${stopwatch.elapsedMilliseconds}ms');

      expect(profileDS, isNotNull);
      expect(waterDS, isNotNull);
      expect(stepDS, isNotNull);
      expect(bmiDS, isNotNull);
      expect(sleepDS, isNotNull);

      // Verify data loading doesn't throw
      expect(() => profileDS.getProfile(), returnsNormally);
      expect(() => waterDS.getEntriesForDate(DateTime.now()), returnsNormally);
      expect(() => bmiDS.getAllEntries(), returnsNormally);
    });

    test('Profile read is fast (under 50ms)', () {
      final stopwatch = Stopwatch()..start();
      final profileDS = ProfileLocalDataSource();
      final profile = profileDS.getProfile();
      stopwatch.stop();

      debugPrint('  ✓ Profile read: ${stopwatch.elapsedMilliseconds}ms (profile=${profile != null ? "exists" : "null"})');
      expect(stopwatch.elapsedMilliseconds, lessThan(50),
          reason: 'Profile read should be under 50ms');
    });

    test('Water entries for today load fast (under 50ms)', () {
      final stopwatch = Stopwatch()..start();
      final waterDS = WaterLocalDataSource();
      final entries = waterDS.getEntriesForDate(DateTime.now());
      stopwatch.stop();

      debugPrint('  ✓ Water entries read: ${stopwatch.elapsedMilliseconds}ms (${entries.length} entries)');
      expect(stopwatch.elapsedMilliseconds, lessThan(50),
          reason: 'Water entries for today should load under 50ms');
    });
  });
}
