import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/animations/animation_helpers.dart';
import '../../data/bmi_entry.dart';
import 'tab_selector_item.dart';

class TrendChartSection extends StatefulWidget {
  final List<BMIEntry> history;
  final double goalMax;
  final double goalMin;

  const TrendChartSection({
    super.key,
    required this.history,
    required this.goalMax,
    required this.goalMin,
  });

  @override
  State<TrendChartSection> createState() => _TrendChartSectionState();
}

class _TrendChartSectionState extends State<TrendChartSection> {
  int _selectedChart = 0; // 0 = Weight Trend, 1 = BMI Trend

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Limit to oldest first (up to 30 entries)
    final entries = widget.history.take(30).toList().reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress Analytics',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            _buildChartSelector(),
          ],
        ),
        const SizedBox(height: 16),
        FadeInWidget(
          delay: const Duration(milliseconds: 150),
          child: Container(
            height: 200,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
            ),
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'Save calculations to view metrics charts',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : LineChart(
                    _buildChartData(entries, theme),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartSelector() {
    final theme = Theme.of(context);
    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          TabSelectorItem(
            label: 'Weight',
            selected: _selectedChart == 0,
            onTap: () => setState(() => _selectedChart = 0),
          ),
          TabSelectorItem(
            label: 'BMI',
            selected: _selectedChart == 1,
            onTap: () => setState(() => _selectedChart = 1),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(List<BMIEntry> entries, ThemeData theme) {
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      final val = _selectedChart == 0 ? entries[i].weightKg : entries[i].bmiValue;
      spots.add(FlSpot(i.toDouble(), val));
    }

    final isWeight = _selectedChart == 0;
    final color = isWeight ? AppColors.tertiary : AppColors.bmi;

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 4,
          color: color,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.15),
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
                val.toStringAsFixed(0),
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
              final dateStr = DateFormat('MM/dd').format(entries[idx].timestamp);
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
}
