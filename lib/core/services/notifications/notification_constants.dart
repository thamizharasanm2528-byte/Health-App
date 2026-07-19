/// Centralised notification constant keys and channel configuration names.
abstract final class NotificationConstants {
  // ── Types of Reminders ──
  static const String typeWater = 'water';
  static const String typeBedtime = 'bedtime';
  static const String typeWakeUp = 'wakeup';
  static const String typeFood = 'food';
  static const String typeWalk = 'walk';
  static const String typeWeight = 'weight';
  static const String typeReport = 'report';

  // ── Repeat Frequencies ──
  static const String repeatNone = 'none';
  static const String repeatDaily = 'daily';
  static const String repeatWeekly = 'weekly';
  static const String repeatHourly = 'hourly';
  static const String repeatCustom = 'custom';

  // ── Android Notification Channels ──
  static const String channelAlarmId = 'wakeup_alarm_channel';
  static const String channelAlarmName = 'Wake-up Alarm';
  static const String channelAlarmDesc = 'Daily wake-up alarms';

  static const String channelReminderId = 'reminders_channel_v2';
  static const String channelReminderName = 'Reminders';
  static const String channelReminderDesc = 'Hydration, Sleep, and Healthy Eating alerts';

  static const String channelAchievementsId = 'achievements_channel';
  static const String channelAchievementsName = 'Achievements';
  static const String channelAchievementsDesc = 'Milestones and badge collection alerts';

  static const String channelReportsId = 'reports_channel';
  static const String channelReportsName = 'Health Reports';
  static const String channelReportsDesc = 'Weekly, monthly, and yearly health reports';

  static const String channelGeneralId = 'general_reminders';
  static const String channelGeneralName = 'General Reminders';
  static const String channelGeneralDesc = 'Walk counts, weigh-ins, and analytics reports';
}
