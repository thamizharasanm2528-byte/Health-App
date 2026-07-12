import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../water_provider.dart';

/// Bar chart showing the last 7 days of water intake.
///
/// Includes weekly average, highest, and lowest stats.
class WeeklyChart extends StatelessWidget {
  final List<DailyIntake> data;
  final double goalLiters;
  final int weeklyAverageMl;
  final int weeklyHighestMl;
  final int weeklyLowestMl;

  const WeeklyChart({
    super.key,
    required this.data,
    required this.goalLiters,
    required this.weeklyAverageMl,
    required this.weeklyHighestMl,
    required this.weeklyLowestMl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Overview',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // ── Bar Chart ──
        Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: BarChart(
            BarChartData(
              maxY: _maxY,
              barGroups: _buildBarGroups(theme),
              titlesData: _buildTitles(theme),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: goalLiters,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.water.withValues(alpha: 0.2),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${(rod.toY * 1000).round()} ml',
                      theme.textTheme.labelSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          ),
        ),

        const SizedBox(height: 16),

        // ── Stats row ──
        Row(
          children: [
            _StatChip(
              label: 'Average',
              value: '${(weeklyAverageMl / 1000).toStringAsFixed(1)}L',
              color: AppColors.water,
            ),
            const SizedBox(width: 8),
            _StatChip(
              label: 'Highest',
              value: '${(weeklyHighestMl / 1000).toStringAsFixed(1)}L',
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            _StatChip(
              label: 'Lowest',
              value: '${(weeklyLowestMl / 1000).toStringAsFixed(1)}L',
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  double get _maxY {
    final maxData =
        data.isEmpty ? 0.0 : data.map((d) => d.totalLiters).reduce((a, b) => a > b ? a : b);
    return (maxData > goalLiters ? maxData : goalLiters) * 1.2;
  }

  List<BarChartGroupData> _buildBarGroups(ThemeData theme) {
    return List.generate(data.length, (i) {
      final d = data[i];
      final metGoal = d.totalLiters >= goalLiters;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: d.totalLiters,
            width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: metGoal
                  ? [AppColors.water, AppColors.water.withValues(alpha: 0.6)]
                  : [
                      AppColors.water.withValues(alpha: 0.4),
                      AppColors.water.withValues(alpha: 0.2),
                    ],
            ),
          ),
        ],
      );
    });
  }

  FlTitlesData _buildTitles(ThemeData theme) {
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
            final day = DateFormat.E().format(data[idx].date);
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                day.substring(0, 2),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            );
          },
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
