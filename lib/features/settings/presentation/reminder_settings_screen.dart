import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alarm/alarm.dart';

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
    
    // Stop any previous test alarms
    await Alarm.stop(9999);

    final triggerTime = DateTime.now().add(const Duration(seconds: 5));
    
    String audioPath = 'assets/water_remainder.mp3';
    if (isBedtime) {
      audioPath = 'assets/bedtime.mp3';
    } else if (reminder.id == 'wakeup') {
      audioPath = 'assets/wakeupalarm.mp3';
    }

    final alarmSettings = AlarmSettings(
      id: 9999, // Test alarm ID
      dateTime: triggerTime,
      assetAudioPath: audioPath,
      loopAudio: false,
      vibrate: reminder.vibrate,
      volumeSettings: const VolumeSettings.fixed(volume: 0.7),
      notificationSettings: NotificationSettings(
        title: '⏰ Test Alert: ${reminder.title}',
        body: reminder.body,
        stopButton: 'Dismiss',
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);

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
