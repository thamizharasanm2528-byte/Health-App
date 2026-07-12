import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

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
        if (kDebugMode) {
          print('HealthService: Configuration failed: $e');
        }
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
      if (kDebugMode) {
        print('HealthService: Health Connect SDK status = $status');
      }
      return status;
    } catch (e) {
      if (kDebugMode) {
        print('HealthService: Failed to get Health Connect status: $e');
      }
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
          if (kDebugMode) {
            print('HealthService: Activity Recognition permission is NOT granted.');
          }
          return false;
        }
      }

      final has = await _health.hasPermissions(_types, permissions: _permissions);
      if (kDebugMode) {
        print('HealthService: Health SDK hasPermissions = $has');
      }
      return has ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('HealthService: Failed to check permissions: $e');
      }
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
          if (kDebugMode) {
            print('HealthService: Activity Recognition permission denied: $status');
          }
          return false;
        }
      }

      // Request authorization from Health Connect / HealthKit
      final granted = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      if (kDebugMode) {
        print('HealthService: requestAuthorization result = $granted');
      }
      return granted;
    } catch (e) {
      if (kDebugMode) {
        print('HealthService: Failed to request authorization: $e');
      }
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

      if (kDebugMode) {
        print('HealthService: Fetching steps from ${start.toIso8601String()} to ${end.toIso8601String()}');
      }

      final steps = await _health.getTotalStepsInInterval(start, end);
      if (kDebugMode) {
        print('HealthService: Fetched steps result = $steps');
      }
      return steps;
    } catch (e) {
      if (kDebugMode) {
        print('HealthService: Failed to fetch steps for interval: $e');
      }
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
