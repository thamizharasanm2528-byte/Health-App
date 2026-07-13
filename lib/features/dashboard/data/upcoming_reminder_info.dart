import 'package:flutter/foundation.dart';

class UpcomingReminderInfo {
  final String title;
  final String description;
  final String countdownText;
  final String emoji;
  final DateTime nextTrigger;
  final VoidCallback onTap;

  UpcomingReminderInfo({
    required this.title,
    required this.description,
    required this.countdownText,
    required this.emoji,
    required this.nextTrigger,
    required this.onTap,
  });
}
