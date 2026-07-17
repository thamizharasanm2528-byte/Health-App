import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/services/notifications/notification_service.dart';
import '../../../core/services/notifications/notification_constants.dart';
import '../../reminders/presentation/reminders_provider.dart';
import '../../reminders/data/reminder_model.dart';
import 'widgets/water_reminder_card.dart';
import 'widgets/bedtime_reminder_card.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final remindersProv = context.watch<RemindersProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Section 2: Water Reminder ──
          WaterReminderCard(
            remindersProv: remindersProv,
            onTestReminder: _triggerTestNotification,
          ),

          const SizedBox(height: 16),

          // ── Section 3: Bedtime Reminder ──
          BedtimeReminderCard(
            remindersProv: remindersProv,
            onTestReminder: _triggerTestNotification,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _triggerTestNotification(ReminderModel reminder) async {
    final isBedtime = reminder.id == 'bedtime';
    final customSound = isBedtime ? 'bedtime' : 'water_remainder';

    // Stop/cancel any previous test notifications
    await NotificationService.instance.plugin.cancel(id: 9999);

    final triggerTime = DateTime.now().add(const Duration(seconds: 5));

    final androidDetails = AndroidNotificationDetails(
      NotificationConstants.channelReminderId,
      NotificationConstants.channelReminderName,
      channelDescription: NotificationConstants.channelReminderDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: reminder.sound,
      sound: reminder.sound ? RawResourceAndroidNotificationSound(customSound) : null,
      vibrationPattern: reminder.vibrate ? Int64List.fromList([0, 1000, 500, 1000]) : null,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: reminder.sound,
      sound: reminder.sound ? '$customSound.mp3' : null,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await NotificationService.instance.scheduler.scheduleOneTime(
      id: 9999,
      title: '🔔 Test Alert: ${reminder.title}',
      body: reminder.body,
      scheduledDate: triggerTime,
      details: details,
    );

    if (mounted) {
      final name = isBedtime ? 'Bedtime' : 'Water';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test $name Notification scheduled in 5 seconds...'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
