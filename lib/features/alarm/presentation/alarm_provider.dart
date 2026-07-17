import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../core/services/notifications/notification_service.dart';
import '../../../core/services/notifications/notification_permission_service.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/services/app_logger.dart';
import '../data/alarm_settings_model.dart';
import '../domain/alarm_engine.dart';
import '../../profile/data/profile_local_data_source.dart';
import '../../reminders/data/reminder_model.dart';
import '../../reminders/domain/reminder_engine.dart';
import '../../reminders/presentation/reminders_provider.dart';
import '../../sleep/presentation/sleep_provider.dart';

class AlarmProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const String boxName = 'alarm_settings_box';
  static const String keyName = 'alarm_settings'; // fallback single key
  
  late Box<AlarmSettingsModel> _box;
  List<AlarmSettingsModel> _alarms = [];
  List<AlarmSettingsModel> get alarms => _alarms;

  String? _lastError;
  String? get lastError => _lastError;

  void clearLastError() {
    if (_lastError != null) {
      _lastError = null;
      notifyListeners();
    }
  }

  final AlarmEngine _engine = AlarmEngine();

  Timer? _vibrationTimer;
  AppLifecycleState? _lifecycleState;
  
  bool _isAlarmScreenVisible = false;
  bool _wokenByAlarm = false;
  bool get wokenByAlarm => _wokenByAlarm;

  AlarmProvider() {
    WidgetsBinding.instance.addObserver(this);
    _init();
    _listenToRing();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
  }

  void _listenToRing() {
    Alarm.ringing.listen((alarmSettings) async {
      if (alarmSettings.alarms.isNotEmpty) {
        final id = alarmSettings.alarms.first.id;

        // Note: Water and bedtime reminders are scheduled natively as recurring/periodic
        // alerts via flutter_local_notifications (retaining custom sounds and persisting
        // across reboots), so manual re-arming loops here are no longer needed.

        if (id >= AlarmEngine.wakeupBaseId) {
          if (!_isAlarmScreenVisible) {
            _isAlarmScreenVisible = true;
            _wokenByAlarm = _lifecycleState == null || _lifecycleState != AppLifecycleState.resumed;

            globalNavigatorKey.currentState?.pushNamed(
              RouteNames.alarmAlert,
              arguments: id,
            ).then((_) {
              _isAlarmScreenVisible = false;
              _wokenByAlarm = false;
            });
          }
        }
      }
    });
  }

  Future<void> _init() async {
    _box = Hive.box<AlarmSettingsModel>(boxName);
    _alarms = _box.values.toList();
    
    if (_alarms.isEmpty) {
      final defaultAlarm = AlarmSettingsModel(
        id: 1,
        isEnabled: false,
        hour: 7,
        minute: 0,
        repeatDays: [1, 2, 3, 4, 5], // default Weekdays
        snoozeDurationMinutes: 10,
        vibrate: true,
        sound: true,
        label: 'Wake-up Alarm',
        isPrimaryWakeup: true,
      );
      await _box.add(defaultAlarm);
      _alarms.add(defaultAlarm);
    }
    
    notifyListeners();
    
    // Defer heavy alarm rescheduling to after the first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAlarmsInBackground();
    });
  }

  /// Reschedules all active alarms in the background after initial UI render.
  Future<void> _syncAlarmsInBackground() async {
    for (final alarm in _alarms) {
      if (alarm.isEnabled) {
        await _engine.scheduleWakeupAlarm(alarm);
      } else {
        await _engine.cancelWakeupAlarm(alarm.id);
      }
    }

    // Note: Water and bedtime reminders are scheduled natively as recurring/periodic
    // alerts via flutter_local_notifications, which persist across app launches and reboots.
    // Therefore, manual re-scheduling logic here is no longer required.
  }

  // ── Getter for single next upcoming alarm (Dashboard/Compatibility) ────

  AlarmSettingsModel? get alarmSettings {
    final enabledAlarms = _alarms.where((a) => a.isEnabled).toList();
    if (enabledAlarms.isEmpty) return null;
    
    final now = DateTime.now();
    enabledAlarms.sort((a, b) {
      final dateA = _getNextTriggerDate(a, now);
      final dateB = _getNextTriggerDate(b, now);
      return dateA.compareTo(dateB);
    });
    return enabledAlarms.first;
  }

  DateTime _getNextTriggerDate(AlarmSettingsModel alarm, DateTime now) {
    final hour = alarm.hour;
    final minute = alarm.minute;
    if (alarm.repeatDays.isEmpty) {
      var next = DateTime(now.year, now.month, now.day, hour, minute);
      if (next.isBefore(now)) {
        next = next.add(const Duration(days: 1));
      }
      return next;
    } else {
      DateTime? earliest;
      for (final day in alarm.repeatDays) {
        var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
        var daysOffset = day - now.weekday;
        if (daysOffset < 0 || (daysOffset == 0 && scheduled.isBefore(now))) {
          daysOffset += 7;
        }
        final target = scheduled.add(Duration(days: daysOffset));
        if (earliest == null || target.isBefore(earliest)) {
          earliest = target;
        }
      }
      return earliest ?? now;
    }
  }

  // ── Formatted displays for UI ─────────────────────────────────────────

  String get formattedTime {
    final settings = alarmSettings;
    if (settings == null) return 'Off';
    return formatTimeOfDay(settings.hour, settings.minute);
  }

  String formatTimeOfDay(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayH = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayH:${minute.toString().padLeft(2, '0')} $period';
  }

  String get formattedRepeatDays {
    final settings = alarmSettings;
    if (settings == null) return '';
    return formatRepeatDaysList(settings.repeatDays);
  }

  String formatRepeatDaysList(List<int> repeatDays) {
    if (repeatDays.isEmpty) {
      return 'Once';
    }
    if (repeatDays.length == 7) {
      return 'Daily';
    }
    final sortedDays = List<int>.from(repeatDays)..sort();
    if (sortedDays.length == 5 &&
        sortedDays.contains(1) &&
        sortedDays.contains(2) &&
        sortedDays.contains(3) &&
        sortedDays.contains(4) &&
        sortedDays.contains(5)) {
      return 'Weekdays';
    }
    if (sortedDays.length == 2 && sortedDays.contains(6) && sortedDays.contains(7)) {
      return 'Weekends';
    }
    
    final daysMapping = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun'
    };
    return sortedDays.map((d) => daysMapping[d]).join(' • ');
  }

  String get nextAlarmText {
    final settings = alarmSettings;
    if (settings == null || !settings.isEnabled) {
      return 'Off';
    }
    return '$formattedTime (${formatRepeatDaysList(settings.repeatDays)})';
  }

  // ── CRUD Methods ──

  Future<void> addAlarm(AlarmSettingsModel alarm) async {
    if (alarm.isEnabled) {
      // Clear primary from all other alarms
      for (final a in _alarms) {
        if (a.isPrimaryWakeup) {
          a.isPrimaryWakeup = false;
          await a.save();
        }
      }
      alarm.isPrimaryWakeup = true;
    } else {
      alarm.isPrimaryWakeup = false;
    }
    await _box.add(alarm);
    _alarms = _box.values.toList();
    if (alarm.isEnabled) {
      await _engine.scheduleWakeupAlarm(alarm);
    }
    notifyListeners();
  }

  Future<void> updateAlarm(AlarmSettingsModel alarm) async {
    if (alarm.isEnabled) {
      // Clear primary from all other alarms except this one
      for (final a in _alarms) {
        if (a.id != alarm.id && a.isPrimaryWakeup) {
          a.isPrimaryWakeup = false;
          await a.save();
        }
      }
      alarm.isPrimaryWakeup = true;
    } else {
      alarm.isPrimaryWakeup = false;
    }

    if (alarm.key != null) {
      await alarm.save();
    } else {
      final idx = _alarms.indexWhere((a) => a.id == alarm.id);
      if (idx != -1) {
        final original = _alarms[idx];
        original.hour = alarm.hour;
        original.minute = alarm.minute;
        original.repeatDays = alarm.repeatDays;
        original.sound = alarm.sound;
        original.vibrate = alarm.vibrate;
        original.snoozeDurationMinutes = alarm.snoozeDurationMinutes;
        original.label = alarm.label;
        original.isEnabled = alarm.isEnabled;
        original.isPrimaryWakeup = alarm.isPrimaryWakeup;
        await original.save();
      } else {
        await _box.add(alarm);
      }
    }
    _alarms = _box.values.toList();
    
    // Reschedule or cancel the alarm depending on enabled state
    if (alarm.isEnabled) {
      await _engine.scheduleWakeupAlarm(alarm);
    } else {
      await _engine.cancelWakeupAlarm(alarm.id);
    }

    if (!alarm.isEnabled) {
      await _autoPromotePrimary();
    }
    
    notifyListeners();
  }

  Future<void> deleteAlarm(int alarmId) async {
    final idx = _alarms.indexWhere((a) => a.id == alarmId);
    if (idx != -1) {
      final alarm = _alarms[idx];
      final wasPrimary = alarm.isPrimaryWakeup;
      await _engine.cancelWakeupAlarm(alarm.id);
      await alarm.delete();
      _alarms = _box.values.toList();
      
      if (wasPrimary) {
        await _autoPromotePrimary();
        _alarms = _box.values.toList();
      }
      notifyListeners();
    }
  }

  Future<AppPermissionStatus> toggleAlarm(int alarmId, bool enabled) async {
    if (enabled) {
      final notifStatus = await NotificationService.instance.permissionService.requestNotificationPermission();
      if (notifStatus == AppPermissionStatus.permanentlyDenied) {
        return AppPermissionStatus.permanentlyDenied;
      }
      if (notifStatus == AppPermissionStatus.denied) {
        return AppPermissionStatus.denied;
      }

      final exactStatus = await NotificationService.instance.permissionService.requestExactAlarmPermission();
      if (exactStatus == AppPermissionStatus.permanentlyDenied) {
        return AppPermissionStatus.permanentlyDenied;
      }
      if (exactStatus == AppPermissionStatus.denied) {
        return AppPermissionStatus.denied;
      }
    }

    final idx = _alarms.indexWhere((a) => a.id == alarmId);
    if (idx != -1) {
      final alarm = _alarms[idx];
      alarm.isEnabled = enabled;
      
      if (enabled) {
        // Clear primary from all other alarms
        for (final a in _alarms) {
          if (a.id != alarm.id && a.isPrimaryWakeup) {
            a.isPrimaryWakeup = false;
            await a.save();
          }
        }
        alarm.isPrimaryWakeup = true;
      } else {
        alarm.isPrimaryWakeup = false;
      }
      
      await alarm.save();
      
      if (enabled) {
        await _engine.scheduleWakeupAlarm(alarm);
      } else {
        await _engine.cancelWakeupAlarm(alarm.id);
        await _autoPromotePrimary();
      }
      
      _alarms = _box.values.toList();
      notifyListeners();
    }
    return AppPermissionStatus.granted;
  }

  Future<void> syncBedtimeWithWakeTime(int wakeHour, int wakeMinute) async {
    try {
      _lastError = null;
      final prefs = await SharedPreferences.getInstance();
      final preferredHours = prefs.getInt('preferred_sleep_duration_hours') ?? 8;
      
      var wakeMinutes = wakeHour * 60 + wakeMinute;
      var bedtimeMinutes = wakeMinutes - (preferredHours * 60);
      if (bedtimeMinutes < 0) bedtimeMinutes += 1440;
      
      final profileDataSource = ProfileLocalDataSource();
      final profile = profileDataSource.getProfile();
      if (profile != null) {
        profile.wakeTimeMinutes = wakeMinutes;
        profile.bedtimeMinutes = bedtimeMinutes;
        await profileDataSource.saveProfile(profile);
      }
      
      final remindersBox = Hive.box<ReminderModel>(RemindersProvider.boxName);
      var bedtimeReminder = remindersBox.get('bedtime');
      if (bedtimeReminder == null) {
        bedtimeReminder = ReminderModel(
          id: 'bedtime',
          type: 'bedtime',
          title: '🛌 Bedtime is approaching!',
          body: 'Wind down and prepare for a restful sleep.',
          isEnabled: true,
          reminderTimes: [bedtimeMinutes],
          repeatDays: [],
          sound: true,
          vibrate: true,
        );
      } else {
        bedtimeReminder.reminderTimes = [bedtimeMinutes];
      }
      await remindersBox.put('bedtime', bedtimeReminder);
      
      final engine = ReminderEngine();
      await engine.rescheduleReminder(bedtimeReminder);
    } catch (e, st) {
      _lastError = 'Failed to sync bedtime settings: $e';
      AppLogger.error('AlarmProvider.syncBedtimeWithWakeTime', e, st);
      notifyListeners();
    }
  }

  // ── Alarm Actions ──────────────────────────────────────────────────────

  Future<void> snoozeAlarm(int alarmId) async {
    // Locate the alarm
    final alarm = _alarms.firstWhere((a) => a.id == alarmId, orElse: () => _alarms.first);
    await _engine.snoozeAlarm(alarm);
    notifyListeners();
  }

  Future<void> dismissAlarm(int alarmId, BuildContext context) async {
    // Retrieve provider before async gap
    final sleepProv = Provider.of<SleepProvider>(context, listen: false);
    
    final alarm = _alarms.firstWhere((a) => a.id == alarmId, orElse: () => _alarms.first);
    await _engine.dismissAlarm(alarm);

    // Sleep Integration
    try {
      await sleepProv.logSleepFromAlarmDismissal();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving sleep on dismissal: $e');
      }
    }
    
    notifyListeners();
  }

  Future<void> testAlarm(AlarmSettingsModel alarm) async {
    await _engine.triggerTestAlarm(alarm);
  }

  Future<void> _autoPromotePrimary() async {
    final enabledAlarms = _alarms.where((a) => a.isEnabled).toList();
    if (enabledAlarms.isEmpty) return;

    final hasPrimary = enabledAlarms.any((a) => a.isPrimaryWakeup);
    if (!hasPrimary) {
      final newPrimary = enabledAlarms.first;
      newPrimary.isPrimaryWakeup = true;
      await newPrimary.save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vibrationTimer?.cancel();
    super.dispose();
  }
}
