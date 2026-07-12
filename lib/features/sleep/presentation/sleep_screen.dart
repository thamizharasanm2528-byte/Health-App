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
                child: _TargetTimesCard(
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
                child: _DurationStatusCard(
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
                child: _SleepRemindersCard(
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
                child: _SleepHistorySection(
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
                  _TabSelectorItem(
                    label: 'Weekly',
                    selected: _selectedChartPeriod == 0,
                    onTap: () => setState(() => _selectedChartPeriod = 0),
                  ),
                  _TabSelectorItem(
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
            _StatChip(
              label: 'Average',
              value: '${stats.averageHours.toStringAsFixed(1)}h',
              color: AppColors.sleep,
            ),
            const SizedBox(width: 8),
            _StatChip(
              label: 'Longest',
              value: '${stats.longestHours.toStringAsFixed(1)}h',
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            _StatChip(
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
            reservedSize: 28,
            getTitlesWidget: (val, meta) {
              return Text(
                '${val.toStringAsFixed(0)}h',
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

  Future<void> _showLogSleepDialog(BuildContext context, SleepProvider provider) async {
    final now = DateTime.now();
    var bedtime = now.subtract(const Duration(hours: 8));
    var wakeTime = now;

    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Log Sleep Session'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Bedtime'),
                    subtitle: Text(DateFormat('MMM dd, hh:mm a').format(bedtime)),
                    trailing: const Icon(Icons.access_time_rounded),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: bedtime,
                        firstDate: now.subtract(const Duration(days: 7)),
                        lastDate: now,
                      );
                      if (pickedDate != null && context.mounted) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(bedtime),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            bedtime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Wake-up Time'),
                    subtitle: Text(DateFormat('MMM dd, hh:mm a').format(wakeTime)),
                    trailing: const Icon(Icons.wb_sunny_rounded),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: wakeTime,
                        firstDate: now.subtract(const Duration(days: 7)),
                        lastDate: now,
                      );
                      if (pickedDate != null && context.mounted) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(wakeTime),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            wakeTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
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
                    provider.logSleep(bedtime: bedtime, wakeTime: wakeTime);
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

// ═══════════════════════════════════════════════════════════════════════════
// Target Times Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _TargetTimesCard extends StatelessWidget {
  final String bedtime;
  final String wakeTime;
  final int bedtimeMinutes;
  final int wakeTimeMinutes;

  const _TargetTimesCard({
    required this.bedtime,
    required this.wakeTime,
    required this.bedtimeMinutes,
    required this.wakeTimeMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Sleep Schedule',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Bedtime (Display Only)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.sleep.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.sleep.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bedtime_rounded, size: 16, color: AppColors.sleep),
                          const SizedBox(width: 6),
                          Text(
                            'Bedtime',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bedtime,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Wake Time (Display Only)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny_rounded, size: 16, color: Colors.orange),
                          const SizedBox(width: 6),
                          Text(
                            'Wake Up',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        wakeTime,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sleep Duration Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _DurationStatusCard extends StatelessWidget {
  final double duration;
  final String status;
  final int consistencyScore;

  const _DurationStatusCard({
    required this.duration,
    required this.status,
    required this.consistencyScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getStatusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expected Duration',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        duration.toStringAsFixed(1),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hours',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule Consistency',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.flash_on_rounded, color: AppColors.tertiary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$consistencyScore%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Color _getStatusColor(String stat) {
    switch (stat.toLowerCase()) {
      case 'excellent':
        return AppColors.success;
      case 'good':
        return AppColors.sleep;
      default:
        return AppColors.warning;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sleep Reminders Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _SleepRemindersCard extends StatelessWidget {
  final bool bedtimeEnabled;
  final bool wakeUpEnabled;
  final VoidCallback onManageBedtime;
  final VoidCallback onManageWakeUp;

  const _SleepRemindersCard({
    required this.bedtimeEnabled,
    required this.wakeUpEnabled,
    required this.onManageBedtime,
    required this.onManageWakeUp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminders & Alerts',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Bedtime Reminder Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bedtime Reminder',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        bedtimeEnabled ? '🟢 ON' : '🔴 OFF',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: bedtimeEnabled ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton.filledTonal(
                onPressed: onManageBedtime,
                icon: const Icon(Icons.settings_outlined, size: 18),
                tooltip: 'Manage Bedtime Reminder',
              ),
            ],
          ),
          const Divider(height: 24),
          // Wake Up Reminder / Alarm Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wake-up Reminder',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        wakeUpEnabled ? '🟢 ON' : '🔴 OFF',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: wakeUpEnabled ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton.filledTonal(
                onPressed: onManageWakeUp,
                icon: const Icon(Icons.alarm_rounded, size: 18),
                tooltip: 'Manage Wake-up Alarm',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Helper widgets
// ═══════════════════════════════════════════════════════════════════════════

class _TabSelectorItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabSelectorItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// History List Widget
// ═══════════════════════════════════════════════════════════════════════════

class _SleepHistorySection extends StatelessWidget {
  final List<SleepRecord> history;
  final ValueChanged<String> onDelete;

  const _SleepHistorySection({required this.history, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sleep Log History',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final rec = history[index];
            final dateStr = DateFormat('EEEE, MMM dd').format(rec.bedtime);
            final durationStr = '${rec.durationHours.toStringAsFixed(1)} hours';

            final timeRange =
                '${DateFormat.jm().format(rec.bedtime)} ➔ ${DateFormat.jm().format(rec.wakeTime)}';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeRange,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.sleep.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rec.status,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.sleep,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        durationStr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        color: theme.colorScheme.error,
                        onPressed: () => onDelete(rec.id),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
