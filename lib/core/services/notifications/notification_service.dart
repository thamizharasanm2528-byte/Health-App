import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz_db;
import '../app_logger.dart';
import 'notification_constants.dart';
import 'notification_model.dart';
import 'notification_permission_service.dart';
import 'scheduler_service.dart';
import '../../routing/app_router.dart';
import '../../routing/route_names.dart';

/// Centralized Notification Engine Service.
/// Manages initialisation, channels setup, permission checking, and database logs persistence.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  
  late final NotificationPermissionService permissionService;
  late final SchedulerService scheduler;

  static const String boxName = 'notification_logs';
  Box<NotificationModel> get _box => Hive.box<NotificationModel>(boxName);

  bool _initialised = false;
  String? lastTriggerTime;

  /// Initializes timezone data, notification channels, and adapters.
  Future<void> init() async {
    if (_initialised) return;

    // ── Init timezone database ──
    tz.initializeTimeZones();

    // ── Setup services ──
    permissionService = NotificationPermissionService();
    scheduler = SchedulerService(plugin);

    // ── Load last trigger time ──
    final prefs = await SharedPreferences.getInstance();
    lastTriggerTime = prefs.getString('last_trigger_time_formatted') ?? 'None';

    // ── Init plugin settings ──
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await instance.updateLastTriggerTime();
        if (response.payload == 'wakeup_alarm') {
          globalNavigatorKey.currentState?.pushNamed(
            RouteNames.alarmAlert,
            arguments: false,
          );
        }
      },
    );

    // ── Check if app launched from notification (Cold Start) ──
    final launchDetails = await plugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      await instance.updateLastTriggerTime();
      final payload = launchDetails.notificationResponse?.payload;
      if (payload == 'wakeup_alarm') {
        Future.delayed(const Duration(milliseconds: 800), () {
          globalNavigatorKey.currentState?.pushNamed(
            RouteNames.alarmAlert,
            arguments: false,
          );
        });
      }
    }

    // ── Register channels on Android ──
    final androidImpl = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImpl != null) {
      await _registerAndroidChannels(androidImpl);
    }

    _initialised = true;
  }

  /// Updates last trigger time to now.
  Future<void> updateLastTriggerTime() async {
    final now = DateTime.now();
    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hour = now.hour;
    final minute = now.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayH = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final timeStr = '${displayH.toString()}:${minute.toString().padLeft(2, '0')} $period';
    final formatted = '${weekdayNames[now.weekday - 1]}, $timeStr';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_trigger_time_formatted', formatted);
    lastTriggerTime = formatted;
  }

  Future<void> _registerAndroidChannels(AndroidFlutterLocalNotificationsPlugin android) async {
    final channels = [
      const AndroidNotificationChannel(
        NotificationConstants.channelAlarmId,
        NotificationConstants.channelAlarmName,
        description: NotificationConstants.channelAlarmDesc,
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        NotificationConstants.channelReminderId,
        NotificationConstants.channelReminderName,
        description: NotificationConstants.channelReminderDesc,
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        NotificationConstants.channelAchievementsId,
        NotificationConstants.channelAchievementsName,
        description: NotificationConstants.channelAchievementsDesc,
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        NotificationConstants.channelReportsId,
        NotificationConstants.channelReportsName,
        description: NotificationConstants.channelReportsDesc,
        importance: Importance.low,
      ),
    ];

    for (final chan in channels) {
      await android.createNotificationChannel(chan);
    }
  }

  // ── Database Configurations Metadata CRUD ──

  /// Persists scheduled reminder metadata configuration.
  Future<void> saveMetadata(NotificationModel model) async {
    await _box.put(model.id, model);
  }

  /// Cancels metadata config entry.
  Future<void> removeMetadata(int id) async {
    await _box.delete(id);
  }

  /// Gets all configuration models.
  List<NotificationModel> getSavedMetadata() {
    return _box.values.toList();
  }

  /// Returns list of pending notification requests from native agent.
  Future<List<PendingNotificationRequest>> getNativePendingRequests() async {
    return await plugin.pendingNotificationRequests();
  }
}
