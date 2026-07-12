import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/step_entry.dart';
import '../step_provider.dart';

/// Interactive toggleable bar chart displaying step count activity weekly (7 days) or monthly (30 days).
class StepChart extends StatefulWidget {
  final List<StepEntry> last30Days;
  final int currentGoal;
  final StepStats Function(List<StepEntry>) calculator;

  const StepChart({
    super.key,
    required this.last30Days,
    required this.currentGoal,
    required this.calculator,
  });

  @override
  State<StepChart> createState() => _StepChartState();
}

class _StepChartState extends State<StepChart> {
  int _selectedTab = 0; // 0 = Weekly, 1 = Monthly

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get current data slice
    final numDays = _selectedTab == 0 ? 7 : 30;
    final entries = widget.last30Days.length >= numDays
        ? widget.last30Days.sublist(widget.last30Days.length - numDays)
        : widget.last30Days;

    final stats = widget.calculator(entries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header + Tab selector ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activity Overview',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            _buildTabSelector(),
          ],
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
              maxY: _getMaxY(entries),
              barGroups: _buildBarGroups(entries, theme),
              titlesData: _buildTitles(entries, theme),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: widget.currentGoal.toDouble(),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.steps.withValues(alpha: 0.2),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()} steps',
                      theme.textTheme.labelSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
        ),

        const SizedBox(height: 16),

        // ── Stats row ──
        Row(
          children: [
            _StatChip(
              label: 'Average',
              value: '${stats.averageSteps}',
              color: AppColors.steps,
            ),
            const SizedBox(width: 8),
            _StatChip(
              label: 'Highest',
              value: '${stats.highestSteps}',
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            _StatChip(
              label: 'Achievement',
              value: '${stats.achievementRatePercent}%',
              color: AppColors.secondary,
            ),
          ],
        ),
      ],
    );
  }

  double _getMaxY(List<StepEntry> entries) {
    if (entries.isEmpty) return widget.currentGoal * 1.2;
    final maxSteps = entries.map((e) => e.steps).reduce((a, b) => a > b ? a : b);
    return (maxSteps > widget.currentGoal ? maxSteps : widget.currentGoal) * 1.2;
  }

  Widget _buildTabSelector() {
    final theme = Theme.of(context);
    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabItem(
            label: 'Weekly',
            isSelected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _TabItem(
            label: 'Monthly',
            isSelected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<StepEntry> entries, ThemeData theme) {
    return List.generate(entries.length, (i) {
      final e = entries[i];
      final metGoal = e.steps >= e.goal;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: e.steps.toDouble(),
            width: _selectedTab == 0 ? 18 : 6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: metGoal
                  ? [AppColors.steps, AppColors.steps.withValues(alpha: 0.6)]
                  : [
                      AppColors.steps.withValues(alpha: 0.4),
                      AppColors.steps.withValues(alpha: 0.2),
                    ],
            ),
          ),
        ],
      );
    });
  }

  FlTitlesData _buildTitles(List<StepEntry> entries, ThemeData theme) {
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
            if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();

            String label;
            if (_selectedTab == 0) {
              label = DateFormat.E().format(entries[idx].date).substring(0, 2);
            } else {
              // Only label every 5 days for monthly to avoid overlapping
              if (idx % 5 == 0 || idx == entries.length - 1) {
                label = DateFormat.d().format(entries[idx].date);
              } else {
                label = '';
              }
            }

            if (label.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
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
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
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
