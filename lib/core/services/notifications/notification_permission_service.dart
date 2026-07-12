import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

enum NotificationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

class NotificationPermissionService {
  /// Request notifications permission.
  Future<AppPermissionStatus> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) return AppPermissionStatus.granted;
    if (status.isPermanentlyDenied) return AppPermissionStatus.permanentlyDenied;
    return AppPermissionStatus.denied;
  }

  /// Request exact alarm permission.
  Future<AppPermissionStatus> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isGranted) return AppPermissionStatus.granted;
      if (status.isPermanentlyDenied) return AppPermissionStatus.permanentlyDenied;
      return AppPermissionStatus.denied;
    }
    return AppPermissionStatus.granted;
  }

  /// Checks if both permissions are granted.
  Future<bool> hasAllPermissions() async {
    final notifGranted = await Permission.notification.isGranted;
    if (Platform.isAndroid) {
      final exactAlarmGranted = await Permission.scheduleExactAlarm.isGranted;
      return notifGranted && exactAlarmGranted;
    }
    return notifGranted;
  }

  /// Opens the app settings window.
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Legacy request notifications permission (returns true if granted).
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Legacy request notification permission status.
  Future<NotificationPermissionStatus> getStatus() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return NotificationPermissionStatus.granted;
    if (status.isPermanentlyDenied) return NotificationPermissionStatus.permanentlyDenied;
    return NotificationPermissionStatus.denied;
  }
}
