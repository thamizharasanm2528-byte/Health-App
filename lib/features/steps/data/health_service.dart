import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/app_logger.dart';

/// Service interfacing with Apple HealthKit or Android Health Connect.
class HealthService {
  final Health _health = Health();
  bool _isConfigured = false;

  static final _types = [HealthDataType.STEPS];
  static final _permissions = [HealthDataAccess.READ_WRITE];

  /// Ensure the health plugin is configured before use
  Future<void> _ensureConfigured() async {
    if (!_isConfigured) {
      try {
        await _health.configure();
        _isConfigured = true;
      } catch (e) {
        AppLogger.error('HealthService.configure', e);
      }
    }
  }

  /// Checks if health data integration is supported on this platform/device.
  Future<bool> isSupported() async {
    try {
      if (kIsWeb) return false;
      await _ensureConfigured();
      return true; // Health package supports both iOS and Android
    } catch (_) {
      return false;
    }
  }

  /// Get the Health Connect SDK Status on Android.
  Future<HealthConnectSdkStatus?> getHealthConnectStatus() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      await _ensureConfigured();
      final status = await _health.getHealthConnectSdkStatus();
      AppLogger.info('HealthService: Health Connect SDK status = $status');
      return status;
    } catch (e) {
      AppLogger.error('HealthService.getHealthConnectStatus', e);
      return null;
    }
  }

  /// Check if permission is already granted.
  Future<bool> hasPermissions() async {
    try {
      final supported = await isSupported();
      if (!supported) return false;

      await _ensureConfigured();

      // On Android, check ACTIVITY_RECOGNITION first
      if (Platform.isAndroid) {
        final activityRecognitionGranted = await Permission.activityRecognition.isGranted;
        if (!activityRecognitionGranted) {
          AppLogger.error('HealthService.hasPermissions', 'Activity Recognition permission is NOT granted.');
          return false;
        }
      }

      final has = await _health.hasPermissions(_types, permissions: _permissions);
      AppLogger.info('HealthService: Health SDK hasPermissions = $has');
      return has ?? false;
    } catch (e) {
      AppLogger.error('HealthService.hasPermissions', e);
      return false;
    }
  }

  /// Request authorization to read/write steps data.
  Future<bool> requestPermissions() async {
    try {
      final supported = await isSupported();
      if (!supported) return false;

      await _ensureConfigured();

      // On Android, request ACTIVITY_RECOGNITION first
      if (Platform.isAndroid) {
        final status = await Permission.activityRecognition.request();
        if (status != PermissionStatus.granted) {
          AppLogger.error('HealthService.requestPermissions', 'Activity Recognition permission denied: $status');
          return false;
        }
      }

      // Request authorization from Health Connect / HealthKit
      final granted = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      AppLogger.info('HealthService: requestAuthorization result = $granted');
      return granted;
    } catch (e) {
      AppLogger.error('HealthService.requestAuthorization', e);
      return false;
    }
  }

  /// Fetches total steps for a specific interval.
  ///
  /// Returns null if query fails, permissions are missing, or unsupported.
  Future<int?> fetchSteps(DateTime start, DateTime end) async {
    try {
      final supported = await isSupported();
      if (!supported) return null;

      await _ensureConfigured();

      AppLogger.info('HealthService: Fetching steps from ${start.toIso8601String()} to ${end.toIso8601String()}');

      final steps = await _health.getTotalStepsInInterval(start, end);
      AppLogger.info('HealthService: Fetched steps result = $steps');
      return steps;
    } catch (e) {
      AppLogger.error('HealthService.fetchSteps', e);
      return null;
    }
  }

  /// Fetches step count for today (midnight to now).
  Future<int?> fetchStepsToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return fetchSteps(start, now);
  }
}
