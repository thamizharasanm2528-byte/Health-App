import 'dart:async';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/animations/animation_helpers.dart';

import '../../../core/theme/app_colors.dart';
import '../../dashboard/presentation/dashboard_provider.dart';
import '../../health_score/presentation/health_score_provider.dart';
import '../data/bmi_entry.dart';
import '../domain/bmi_recommendation_engine.dart';
import 'bmi_provider.dart';

/// BMIScreen — complete BMI & Personalized Health Plan feature.
class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize controllers with a post-frame callback to grab loaded provider values
    _heightController = TextEditingController();
    _weightController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BmiProvider>(context, listen: false);
      _heightController.text = provider.heightCm.toStringAsFixed(1);
      _weightController.text = provider.weightKg.toStringAsFixed(1);
    });
  }

  void _triggerAutoSave(BmiProvider provider) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 800), () async {
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        final height = double.tryParse(_heightController.text);
        final weight = double.tryParse(_weightController.text);
        if (height != null && weight != null) {
          provider.updateHeight(height);
          provider.updateWeight(weight);
          await provider.saveCurrentBmi();
        }
      }
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _tabController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<BmiProvider>();

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
                      Icons.monitor_weight_rounded,
                      color: AppColors.bmi,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'BMI & Health Plan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
              const SizedBox(height: 16),

              // ── Calculator Input Card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCalculatorCard(context, provider),
              ),
              const SizedBox(height: 20),

              // ── Main BMI Result indicator ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _BmiResultCard(
                  bmi: provider.bmiValue,
                  category: provider.bmiCategory,
                ),
              ),
              const SizedBox(height: 20),

              // ── Healthy Weight Range & Goals Card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _HealthyWeightCard(
                  range: provider.healthyWeightRange,
                  currentWeight: provider.currentWeight,
                  targetWeight: provider.targetWeight,
                  difference: provider.weightDifference,
                  progress: provider.weightGoalProgress,
                  goalMessage: provider.weightGoalMessage,
                  onUpdateTarget: (val) async {
                    await provider.updateTargetWeight(val);
                    if (context.mounted) {
                      context.read<DashboardProvider>().refreshAll();
                      context.read<HealthScoreProvider>().refreshAll();
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ── Recommendations Card ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _RecommendationsCard(
                  category: provider.bmiCategory,
                ),
              ),
              const SizedBox(height: 24),

              // ── Trend Line Charts ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _TrendChartSection(
                  history: provider.history,
                  goalMax: provider.healthyWeightMax,
                  goalMin: provider.healthyWeightMin,
                ),
              ),
              const SizedBox(height: 24),

              // ── History List ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _BmiHistorySection(
                  history: provider.history,
                  onDelete: (id) async {
                    await provider.deleteBmiLog(id);
                    if (context.mounted) {
                      context.read<DashboardProvider>().refreshAll();
                      context.read<HealthScoreProvider>().refreshAll();
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    }

  Widget _buildCalculatorCard(BuildContext context, BmiProvider provider) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Your Metrics',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                // Height Field
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      suffixText: 'cm',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter height';
                      final parsed = double.tryParse(val);
                      if (parsed == null || parsed < 50 || parsed > 250) {
                        return '50 to 250 cm';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed >= 50 && parsed <= 250) {
                        provider.updateHeight(parsed);
                        _triggerAutoSave(provider);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 14),
                // Weight Field
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter weight';
                      final parsed = double.tryParse(val);
                      if (parsed == null || parsed < 10 || parsed > 300) {
                        return '10 to 300 kg';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed >= 10 && parsed <= 300) {
                        provider.updateWeight(parsed);
                        _triggerAutoSave(provider);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BMI Result Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _BmiResultCard extends StatelessWidget {
  final double bmi;
  final String category;

  const _BmiResultCard({required this.bmi, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getCategoryColor(category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Calculated BMI',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 10.0, end: bmi),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Text(
                val.toStringAsFixed(1),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 54,
                  color: color,
                  letterSpacing: -1,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey<String>(category),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Circular visual gauge representation
          _buildGaugeBar(bmi, color),
        ],
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'underweight':
        return Colors.blue;
      case 'healthy':
        return AppColors.success;
      case 'overweight':
        return Colors.orange;
      case 'obese':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  Widget _buildGaugeBar(double score, Color categoryColor) {
    return Column(
      children: [
        BmiGauge(
          bmi: score,
          themeColor: categoryColor,
        ),
        const SizedBox(height: 16),
        // Indicator marks
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15.0 (Under)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
            Text('18.5 (Normal)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success)),
            Text('25.0 (Over)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
            Text('30.0 (Obese)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error)),
          ],
        )
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Healthy Weight Range & Goals Card
// ═══════════════════════════════════════════════════════════════════════════

class _HealthyWeightCard extends StatelessWidget {
  final String range;
  final double currentWeight;
  final double targetWeight;
  final double difference;
  final double progress;
  final String goalMessage;
  final ValueChanged<double> onUpdateTarget;

  const _HealthyWeightCard({
    required this.range,
    required this.currentWeight,
    required this.targetWeight,
    required this.difference,
    required this.progress,
    required this.goalMessage,
    required this.onUpdateTarget,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Healthy Weight Target',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                color: AppColors.bmi,
                onPressed: () => _showTargetDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Recommended Range: ', style: TextStyle(fontSize: 13)),
              Text(
                range,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              _buildMetricCol(context, 'Current', '${currentWeight.toStringAsFixed(1)} kg'),
              _buildDivider(),
              _buildMetricCol(context, 'Target', '${targetWeight.toStringAsFixed(1)} kg'),
              _buildDivider(),
              _buildMetricCol(context, 'Diff', '${difference.toStringAsFixed(1)} kg'),
            ],
          ),
          const SizedBox(height: 16),
          // Goal Progress Slider Bar
          Text(
            'Target Progress',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutCubic,
            builder: (context, animVal, child) {
              return Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: animVal,
                        minHeight: 8,
                        backgroundColor: AppColors.bmi.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation(AppColors.bmi),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(animVal * 100).round()}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.bmi,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            goalMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(BuildContext context, String title, String val) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Future<void> _showTargetDialog(BuildContext context) async {
    final controller = TextEditingController(text: targetWeight.toStringAsFixed(1));
    final formKey = GlobalKey<FormState>();
    final shakeKey = GlobalKey<ShakeWidgetState>();

    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Edit Target Weight'),
          content: Form(
            key: formKey,
            child: ShakeWidget(
              key: shakeKey,
              child: TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Target Weight (kg)',
                  suffixText: 'kg',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter target';
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed < 10 || parsed > 300) {
                    return 'Enter 10 to 300 kg';
                  }
                  return null;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final target = double.parse(controller.text);
                  onUpdateTarget(target);
                  Navigator.pop(ctx);
                } else {
                  shakeKey.currentState?.shake();
                  HapticFeedback.heavyImpact();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Personalized Recommendation Plan Card
// ═══════════════════════════════════════════════════════════════════════════

class _RecommendationsCard extends StatelessWidget {
  final String category;

  const _RecommendationsCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recommendations = BmiRecommendationEngine.getRecommendations(category);

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
          Row(
            children: [
              const Icon(Icons.spa_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'Personalized Health Plan',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...recommendations.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Trend Charts Widget
// ═══════════════════════════════════════════════════════════════════════════

class _TrendChartSection extends StatefulWidget {
  final List<BMIEntry> history;
  final double goalMax;
  final double goalMin;

  const _TrendChartSection({
    required this.history,
    required this.goalMax,
    required this.goalMin,
  });

  @override
  State<_TrendChartSection> createState() => _TrendChartSectionState();
}

class _TrendChartSectionState extends State<_TrendChartSection> {
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
          _TabSelectorItem(
            label: 'Weight',
            selected: _selectedChart == 0,
            onTap: () => setState(() => _selectedChart = 0),
          ),
          _TabSelectorItem(
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

// ═══════════════════════════════════════════════════════════════════════════
// Calculation History List
// ═══════════════════════════════════════════════════════════════════════════

class _BmiHistorySection extends StatelessWidget {
  final List<BMIEntry> history;
  final ValueChanged<String> onDelete;

  const _BmiHistorySection({required this.history, required this.onDelete});

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
          'Calculation History',
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
            final entry = history[index];
            final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(entry.timestamp);
            final delayMs = (index * 50).clamp(0, 300);

            return FadeInWidget(
              delay: Duration(milliseconds: delayMs),
              child: Dismissible(
                key: ValueKey(entry.id),
                direction: DismissDirection.endToStart,
                // Perform deletion inside confirmDismiss and return false.
                // Returning false prevents the Dismissible from entering the
                // "dismissed" state. The provider's notifyListeners() call
                // rebuilds the list without this entry, removing it from the
                // widget tree cleanly — no "dismissed widget still in tree" error.
                confirmDismiss: (direction) async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete BMI Record'),
                      content: const Text(
                        'Are you sure you want to permanently delete this BMI history log?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(
                            'Delete',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    onDelete(entry.id);
                    if (context.mounted) {
                      HealthSnackBar.showSuccess(
                        context,
                        'BMI entry deleted successfully! 🗑️',
                      );
                    }
                  }
                  // Always return false — the item is removed by provider rebuild,
                  // not by the Dismissible's own dismiss lifecycle.
                  return false;
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMI: ${entry.bmiValue.toStringAsFixed(1)} (${entry.category})',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Weight: ${entry.weightKg.toStringAsFixed(1)} kg | Height: ${entry.heightCm.toStringAsFixed(0)} cm',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        color: theme.colorScheme.error,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete BMI Record'),
                              content: const Text(
                                'Are you sure you want to permanently delete this BMI history log?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: theme.colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            onDelete(entry.id);
                            if (context.mounted) {
                              HealthSnackBar.showSuccess(
                                context,
                                'BMI entry deleted successfully! 🗑️',
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class BmiGauge extends StatelessWidget {
  final double bmi;
  final Color themeColor;

  const BmiGauge({
    super.key,
    required this.bmi,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    if (disableAnimations) {
      return RepaintBoundary(
        child: CustomPaint(
          size: const Size(220, 120),
          painter: BmiGaugePainter(bmi: bmi, themeColor: themeColor),
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 15.0, end: bmi),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutBack,
      builder: (context, animBmi, child) {
        return RepaintBoundary(
          child: CustomPaint(
            size: const Size(220, 120),
            painter: BmiGaugePainter(bmi: animBmi, themeColor: themeColor),
          ),
        );
      },
    );
  }
}

class BmiGaugePainter extends CustomPainter {
  final double bmi;
  final Color themeColor;

  BmiGaugePainter({required this.bmi, required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = size.width / 2 - 10;
    
    // Draw semi-circle track
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final startAngle = math.pi;
    final totalSweep = math.pi;

    // We map BMI from 15 to 35 (range = 20)
    // Draw segments: Underweight (15 to 18.5 -> 3.5 units)
    paint.color = Colors.blue.withValues(alpha: 0.8);
    canvas.drawArc(rect, startAngle, totalSweep * (3.5 / 20.0), false, paint);

    // Healthy (18.5 to 25.0 -> 6.5 units)
    paint.color = AppColors.success.withValues(alpha: 0.8);
    canvas.drawArc(rect, startAngle + totalSweep * (3.5 / 20.0), totalSweep * (6.5 / 20.0), false, paint);

    // Overweight (25.0 to 30.0 -> 5.0 units)
    paint.color = Colors.orange.withValues(alpha: 0.8);
    canvas.drawArc(rect, startAngle + totalSweep * (10.0 / 20.0), totalSweep * (5.0 / 20.0), false, paint);

    // Obese (30.0 to 35.0 -> 5.0 units)
    paint.color = AppColors.error.withValues(alpha: 0.8);
    canvas.drawArc(rect, startAngle + totalSweep * (15.0 / 20.0), totalSweep * (5.0 / 20.0), false, paint);

    // Calculate needle angle
    final fraction = ((bmi - 15.0) / 20.0).clamp(0.0, 1.0);
    final needleAngle = math.pi + fraction * math.pi;

    // Draw needle
    final needlePaint = Paint()
      ..color = themeColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final needleLength = radius - 15;
    final tip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );
    canvas.drawLine(center, tip, needlePaint);

    // Draw pivot center
    final pivotPaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, pivotPaint);

    final pivotCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, pivotCenterPaint);
  }

  @override
  bool shouldRepaint(covariant BmiGaugePainter oldDelegate) {
    return oldDelegate.bmi != bmi || oldDelegate.themeColor != themeColor;
  }
}
