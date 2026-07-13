import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../alarm/presentation/alarm_provider.dart';
import '../../reminders/presentation/reminders_provider.dart';
import '../data/sleep_record.dart';
import 'sleep_provider.dart';
import 'widgets/target_times_card.dart';
import 'widgets/duration_status_card.dart';
import 'widgets/sleep_reminders_card.dart';
import 'widgets/tab_selector_item.dart';
import 'widgets/stat_chip.dart';
import 'widgets/sleep_history_section.dart';

/// SleepScreen — complete sleep management feature.
class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  int _selectedChartPeriod = 0; // 0 = Weekly, 1 = Monthly

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SleepProvider>();
    final remindersProv = context.watch<RemindersProvider>();
    final alarmProv = context.watch<AlarmProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bedtime_rounded,
                      color: AppColors.sleep,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Sleep Management',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Target Times Card (Bedtime & Wake-up) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TargetTimesCard(
                bedtime: provider.bedtimeFormatted,
                wakeTime: provider.wakeTimeFormatted,
                bedtimeMinutes: provider.bedtimeMinutes,
                wakeTimeMinutes: provider.wakeTimeMinutes,
              ),
            ),
            const SizedBox(height: 20),

            // ── Expected Duration & Status Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DurationStatusCard(
                duration: provider.expectedSleepDurationHours,
                status: provider.getSleepStatus(provider.expectedSleepDurationHours),
                consistencyScore: provider.sleepConsistencyScore,
              ),
            ),
            const SizedBox(height: 20),

            // ── Log Sleep Button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () => _showLogSleepDialog(context, provider),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.sleep,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text(
                    'Log Last Night\'s Sleep',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Reminders & Alarm Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SleepRemindersCard(
                bedtimeEnabled: remindersProv.getReminderById(
                  'bedtime',
                  type: 'bedtime',
                  title: '🛌 Bedtime is approaching!',
                  body: 'Wind down and prepare for a restful sleep.',
                  defaultTimes: [1350],
                ).isEnabled,
                wakeUpEnabled: alarmProv.alarms.any((a) => a.isEnabled),
                onManageBedtime: () {
                  Navigator.pushNamed(context, RouteNames.reminderSettings);
                },
                onManageWakeUp: () {
                  Navigator.pushNamed(context, RouteNames.alarm);
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── Sleep Progress Trends ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTrendSection(provider),
            ),
            const SizedBox(height: 24),

            // ── Log history list ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SleepHistorySection(
                history: provider.history,
                onDelete: (id) => provider.deleteSleepRecord(id),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendSection(SleepProvider provider) {
    final theme = Theme.of(context);
    final days = _selectedChartPeriod == 0 ? 7 : 30;
    final entries = provider.getRangeEntries(days);
    final stats = provider.calculateStats(entries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sleep Trends',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              height: 32,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  TabSelectorItem(
                    label: 'Weekly',
                    selected: _selectedChartPeriod == 0,
                    onTap: () => setState(() => _selectedChartPeriod = 0),
                  ),
                  TabSelectorItem(
                    label: 'Monthly',
                    selected: _selectedChartPeriod == 1,
                    onTap: () => setState(() => _selectedChartPeriod = 1),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
          ),
          child: entries.isEmpty
              ? Center(
                  child: Text(
                    'Log sleep entries to view analytics',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : LineChart(
                  _buildChartData(entries, theme),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            StatChip(
              label: 'Average',
              value: '${stats.averageHours.toStringAsFixed(1)}h',
              color: AppColors.sleep,
            ),
            const SizedBox(width: 8),
            StatChip(
              label: 'Longest',
              value: '${stats.longestHours.toStringAsFixed(1)}h',
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            StatChip(
              label: 'Goal Met',
              value: '${stats.goalAchievementPercent}%',
              color: AppColors.secondary,
            ),
          ],
        ),
      ],
    );
  }

  LineChartData _buildChartData(List<SleepRecord> entries, ThemeData theme) {
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].durationHours));
    }

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 4,
          color: AppColors.sleep,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.sleep.withValues(alpha: 0.15),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (val, meta) {
              return Text(
                '${val.toStringAsFixed(1)}h',
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (val, meta) {
              final idx = val.toInt();
              if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
              final dateStr = DateFormat('MM/dd').format(entries[idx].bedtime);
              return Text(
                dateStr,
                style: theme.textTheme.labelSmall?.copyWith(fontSize: 8),
              );
            },
          ),
        ),
      ),
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
    );
  }

  void _showLogSleepDialog(BuildContext context, SleepProvider provider) {
    TimeOfDay bedtime = const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay wakeTime = const TimeOfDay(hour: 6, minute: 0);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Log Sleep Record'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Bedtime'),
                    trailing: Text(bedtime.format(context)),
                    onTap: () async {
                      final selected = await showTimePicker(
                        context: context,
                        initialTime: bedtime,
                      );
                      if (selected != null) {
                        setDialogState(() => bedtime = selected);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Wake Up Time'),
                    trailing: Text(wakeTime.format(context)),
                    onTap: () async {
                      final selected = await showTimePicker(
                        context: context,
                        initialTime: wakeTime,
                      );
                      if (selected != null) {
                        setDialogState(() => wakeTime = selected);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final now = DateTime.now();
                    final bedDate = DateTime(now.year, now.month, now.day, bedtime.hour, bedtime.minute);
                    final wakeDate = DateTime(now.year, now.month, now.day, wakeTime.hour, wakeTime.minute);
                    provider.logSleep(bedtime: bedDate, wakeTime: wakeDate);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sleep log saved!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
