import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../dashboard/presentation/dashboard_provider.dart';
import '../../health_score/presentation/health_score_provider.dart';
import 'bmi_provider.dart';
import 'widgets/bmi_result_card.dart';
import 'widgets/healthy_weight_card.dart';
import 'widgets/recommendations_card.dart';
import 'widgets/trend_chart_section.dart';
import 'widgets/bmi_history_section.dart';

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
              child: BmiResultCard(
                bmi: provider.bmiValue,
                category: provider.bmiCategory,
              ),
            ),
            const SizedBox(height: 20),

            // ── Healthy Weight Range & Goals Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HealthyWeightCard(
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
              child: RecommendationsCard(
                category: provider.bmiCategory,
              ),
            ),
            const SizedBox(height: 24),

            // ── Trend Line Charts ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TrendChartSection(
                history: provider.history,
                goalMax: provider.healthyWeightMax,
                goalMin: provider.healthyWeightMin,
              ),
            ),
            const SizedBox(height: 24),

            // ── History List ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BmiHistorySection(
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
