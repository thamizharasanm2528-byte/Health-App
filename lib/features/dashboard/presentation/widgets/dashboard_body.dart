import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/animations/animation_helpers.dart';
import '../../../../shared/widgets/common_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../alarm/presentation/alarm_provider.dart';
import '../../../health_score/presentation/health_score_provider.dart';
import '../../../reminders/presentation/reminders_provider.dart';
import '../../data/upcoming_reminder_info.dart';
import '../dashboard_provider.dart';
import 'greeting_header.dart';
import 'health_score_card.dart';
import 'progress_card.dart';

class DashboardBody extends StatefulWidget {
  final DashboardProvider provider;
  const DashboardBody({super.key, required this.provider});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting Header ──
            GreetingHeaderClock(
              userName: provider.userName,
              onNotificationTap: () => Navigator.pushNamed(
                context,
                RouteNames.reminderSettings,
              ),
              onAvatarTap: () {
                HapticFeedback.selectionClick();
                provider.setTabIndex(5);
              },
            ),

            const SizedBox(height: 24),

            // ── Card 1: Health Score (Hero) ──
            Consumer<HealthScoreProvider>(
              builder: (context, healthProv, child) {
                return HealthScoreCard(
                  scorePercent: healthProv.todayScore.totalScore.round(),
                  message: healthProv.motivationMessage.isNotEmpty
                      ? healthProv.motivationMessage
                      : healthProv.todayScore.message,
                );
              },
            ),

            const SizedBox(height: 28),

            // ── Card 2: Today's Quick Progress ──
            const SectionHeader(
              title: "Today's Quick Progress",
              subtitle: "Tap cards to open dedicated trackers",
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FadeInWidget(
                          delay: Duration.zero,
                          child: ProgressCard(
                            title: 'Water',
                            value: '${provider.waterIntake.toStringAsFixed(1)}L',
                            subtitle: 'Goal: ${provider.waterGoal.toStringAsFixed(1)}L',
                            icon: Icons.water_drop_rounded,
                            color: AppColors.water,
                            progress: provider.waterProgress,
                            onAction: () => provider.setTabIndex(1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FadeInWidget(
                          delay: const Duration(milliseconds: 60),
                          child: ProgressCard(
                            title: 'Steps',
                            value: '${provider.todaySteps}',
                            subtitle: 'Goal: ${provider.stepGoal}',
                            icon: Icons.directions_walk_rounded,
                            color: AppColors.steps,
                            progress: provider.stepProgress,
                            onAction: () => provider.setTabIndex(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FadeInWidget(
                          delay: const Duration(milliseconds: 120),
                          child: ProgressCard(
                            title: 'Sleep',
                            value: '${provider.lastNightSleep.toStringAsFixed(1)}h',
                            subtitle: 'Target: ${provider.sleepTarget.toStringAsFixed(0)}h',
                            icon: Icons.bedtime_rounded,
                            color: AppColors.sleep,
                            progress: provider.sleepProgress,
                            onAction: () => provider.setTabIndex(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FadeInWidget(
                          delay: const Duration(milliseconds: 180),
                          child: ProgressCard(
                            title: 'BMI',
                            value: provider.currentBmi > 0 ? provider.currentBmi.toStringAsFixed(1) : '--',
                            subtitle: 'Goal: ${provider.targetWeight.toStringAsFixed(0)} kg',
                            icon: Icons.monitor_weight_rounded,
                            color: AppColors.bmi,
                            progress: provider.currentBmi > 0 ? ((provider.currentBmi - 10) / 30).clamp(0.0, 1.0) : 0,
                            onAction: () => provider.setTabIndex(3),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FadeInWidget(
                              delay: Duration.zero,
                              child: ProgressCard(
                                title: 'Water',
                                value: '${provider.waterIntake.toStringAsFixed(1)}L',
                                subtitle: 'Goal: ${provider.waterGoal.toStringAsFixed(1)}L',
                                icon: Icons.water_drop_rounded,
                                color: AppColors.water,
                                progress: provider.waterProgress,
                                onAction: () => provider.setTabIndex(1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FadeInWidget(
                              delay: const Duration(milliseconds: 60),
                              child: ProgressCard(
                                title: 'Steps',
                                value: '${provider.todaySteps}',
                                subtitle: 'Goal: ${provider.stepGoal}',
                                icon: Icons.directions_walk_rounded,
                                color: AppColors.steps,
                                progress: provider.stepProgress,
                                onAction: () => provider.setTabIndex(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FadeInWidget(
                              delay: const Duration(milliseconds: 120),
                              child: ProgressCard(
                                title: 'Sleep',
                                value: '${provider.lastNightSleep.toStringAsFixed(1)}h',
                                subtitle: 'Target: ${provider.sleepTarget.toStringAsFixed(0)}h',
                                icon: Icons.bedtime_rounded,
                                color: AppColors.sleep,
                                progress: provider.sleepProgress,
                                onAction: () => provider.setTabIndex(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FadeInWidget(
                              delay: const Duration(milliseconds: 180),
                              child: ProgressCard(
                                title: 'BMI',
                                value: provider.currentBmi > 0 ? provider.currentBmi.toStringAsFixed(1) : '--',
                                subtitle: 'Goal: ${provider.targetWeight.toStringAsFixed(0)} kg',
                                icon: Icons.monitor_weight_rounded,
                                color: AppColors.bmi,
                                progress: provider.currentBmi > 0 ? ((provider.currentBmi - 10) / 30).clamp(0.0, 1.0) : 0,
                                onAction: () => provider.setTabIndex(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 28),

            // ── Card 3: Upcoming Reminder ──
            const SectionHeader(title: "Upcoming Reminder"),
            const SizedBox(height: 12),
            Consumer2<AlarmProvider, RemindersProvider>(
              builder: (context, alarmProv, remindersProv, child) {
                final nearest = _getNearestReminder(context, alarmProv, remindersProv);
                if (nearest == null) {
                  return CommonCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        const Text('🔔', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'No upcoming reminders scheduled today.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, RouteNames.settings),
                          child: const Text('Manage'),
                        ),
                      ],
                    ),
                  );
                }

                return CommonCard(
                  padding: const EdgeInsets.all(16),
                  onTap: nearest.onTap,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(nearest.emoji, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nearest.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    nearest.description,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: StatusChip(
                                    key: ValueKey<String>(nearest.countdownText),
                                    label: nearest.countdownText,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // ── Weekly Summary Button ──
            Center(
              child: FilledButton.icon(
                onPressed: () => _showWeeklySummaryBottomSheet(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.analytics_rounded),
                label: const Text(
                  'View Weekly Summary',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showWeeklySummaryBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final healthProv = context.read<HealthScoreProvider>();
    final averages = healthProv.getWeeklyAverages();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Health Summary',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Averages computed on the fly from the past 7 days.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Health Score Circular Widget
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              value: (averages['avgScore'] ?? 0.0) / 100.0,
                              strokeWidth: 8,
                              color: theme.colorScheme.primary,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          Text(
                            '${(averages['avgScore'] ?? 0.0).round()}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avg Health Score',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Overall completion index',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Grid of Averages
              Row(
                children: [
                  Expanded(
                    child: _buildAverageCard(
                      context,
                      title: 'Water Intake',
                      value: '${(averages['avgWaterL'] ?? 0.0).toStringAsFixed(1)} L',
                      icon: Icons.water_drop_rounded,
                      color: AppColors.water,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAverageCard(
                      context,
                      title: 'Steps Count',
                      value: '${(averages['avgSteps'] ?? 0.0).round()}',
                      icon: Icons.directions_walk_rounded,
                      color: AppColors.steps,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAverageCard(
                      context,
                      title: 'Sleep Duration',
                      value: '${(averages['avgSleep'] ?? 0.0).toStringAsFixed(1)} hrs',
                      icon: Icons.bedtime_rounded,
                      color: AppColors.sleep,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAverageCard(
                      context,
                      title: 'Weight Logged',
                      value: '${healthProv.profileDataSource.getProfile()?.weightKg.toStringAsFixed(1) ?? '--'} kg',
                      icon: Icons.monitor_weight_rounded,
                      color: AppColors.bmi,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAverageCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  UpcomingReminderInfo? _getNearestReminder(
    BuildContext context,
    AlarmProvider alarmProv,
    RemindersProvider remindersProv,
  ) {
    final now = DateTime.now();
    final list = <UpcomingReminderInfo>[];

    // 1. Wake-up Alarm
    final alarmSettings = alarmProv.alarmSettings;
    if (alarmSettings != null && alarmSettings.isEnabled) {
      final hour = alarmSettings.hour;
      final minute = alarmSettings.minute;
      DateTime nextAlarm;
      if (alarmSettings.repeatDays.isEmpty) {
        nextAlarm = DateTime(now.year, now.month, now.day, hour, minute);
        if (nextAlarm.isBefore(now)) {
          nextAlarm = nextAlarm.add(const Duration(days: 1));
        }
      } else {
        DateTime? earliest;
        for (final day in alarmSettings.repeatDays) {
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
        nextAlarm = earliest ?? now;
      }

      final diff = nextAlarm.difference(now);
      final countdown = _formatCountdown(diff);
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayH = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final timeStr = '${displayH.toString()}:${minute.toString().padLeft(2, '0')} $period';
      final desc = nextAlarm.day == now.day ? 'Today at $timeStr' : 'Tomorrow at $timeStr';

      list.add(UpcomingReminderInfo(
        title: 'Wake-up Alarm',
        description: desc,
        countdownText: countdown,
        emoji: '⏰',
        nextTrigger: nextAlarm,
        onTap: () => Navigator.pushNamed(context, RouteNames.alarm),
      ));
    }

    for (final reminder in remindersProv.reminders) {
      if (!reminder.isEnabled || reminder.type == 'food') continue;
      final nextOcc = remindersProv.getNextOccurrence(reminder);
      if (nextOcc == null) continue;

      final diff = nextOcc.difference(now);
      final countdown = _formatCountdown(diff);

      if (reminder.reminderTimes.isEmpty) continue;
      final hour = nextOcc.hour;
      final minute = nextOcc.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayH = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final timeStr = '${displayH.toString()}:${minute.toString().padLeft(2, '0')} $period';
      
      String prefix = 'Reminder';
      if (reminder.type == 'water') {
        prefix = 'Water';
      } else if (reminder.type == 'bedtime') {
        prefix = 'Sleep';
      }
      
      final desc = '$prefix at $timeStr';

      String emoji = '🔔';
      VoidCallback onTap = () {};
      if (reminder.type == 'water') {
        emoji = '💧';
        onTap = () => context.read<DashboardProvider>().setTabIndex(1);
      } else if (reminder.type == 'bedtime') {
        emoji = '🛌';
        onTap = () => context.read<DashboardProvider>().setTabIndex(4);
      }

      list.add(UpcomingReminderInfo(
        title: reminder.title,
        description: desc,
        countdownText: countdown,
        emoji: emoji,
        nextTrigger: nextOcc,
        onTap: onTap,
      ));
    }

    if (list.isEmpty) return null;

    list.sort((a, b) => a.nextTrigger.compareTo(b.nextTrigger));
    return list.first;
  }

  String _formatCountdown(Duration diff) {
    final minutes = diff.inMinutes;
    if (minutes < 60) {
      return 'in $minutes min';
    }
    final hours = diff.inHours;
    final remainingMinutes = minutes % 60;
    if (hours < 24) {
      return remainingMinutes > 0 ? 'in $hours hr $remainingMinutes min' : 'in $hours hr';
    }
    final days = diff.inDays;
    return 'in $days days';
  }
}
