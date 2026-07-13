import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/animations/animation_helpers.dart';
import '../dashboard_provider.dart';
import 'progress_card.dart';

class _ProgressCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;
  final VoidCallback onAction;
  final Duration delay;

  _ProgressCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
    required this.onAction,
    required this.delay,
  });
}

class QuickProgressSection extends StatelessWidget {
  final DashboardProvider provider;

  const QuickProgressSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final List<_ProgressCardData> cards = [
      _ProgressCardData(
        title: 'Water',
        value: '${provider.waterIntake.toStringAsFixed(1)}L',
        subtitle: 'Goal: ${provider.waterGoal.toStringAsFixed(1)}L',
        icon: Icons.water_drop_rounded,
        color: AppColors.water,
        progress: provider.waterProgress,
        onAction: () => provider.setTabIndex(1),
        delay: Duration.zero,
      ),
      _ProgressCardData(
        title: 'Steps',
        value: '${provider.todaySteps}',
        subtitle: 'Goal: ${provider.stepGoal}',
        icon: Icons.directions_walk_rounded,
        color: AppColors.steps,
        progress: provider.stepProgress,
        onAction: () => provider.setTabIndex(2),
        delay: const Duration(milliseconds: 60),
      ),
      _ProgressCardData(
        title: 'Sleep',
        value: '${provider.lastNightSleep.toStringAsFixed(1)}h',
        subtitle: 'Target: ${provider.sleepTarget.toStringAsFixed(0)}h',
        icon: Icons.bedtime_rounded,
        color: AppColors.sleep,
        progress: provider.sleepProgress,
        onAction: () => provider.setTabIndex(4),
        delay: const Duration(milliseconds: 120),
      ),
      _ProgressCardData(
        title: 'BMI',
        value: provider.currentBmi > 0 ? provider.currentBmi.toStringAsFixed(1) : '--',
        subtitle: 'Goal: ${provider.targetWeight.toStringAsFixed(0)} kg',
        icon: Icons.monitor_weight_rounded,
        color: AppColors.bmi,
        progress: provider.currentBmi > 0 ? ((provider.currentBmi - 10) / 30).clamp(0.0, 1.0) : 0,
        onAction: () => provider.setTabIndex(3),
        delay: const Duration(milliseconds: 180),
      ),
    ];

    final widgets = cards.map((card) {
      return FadeInWidget(
        delay: card.delay,
        child: ProgressCard(
          title: card.title,
          value: card.value,
          subtitle: card.subtitle,
          icon: card.icon,
          color: card.color,
          progress: card.progress,
          onAction: card.onAction,
        ),
      );
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: widgets[0]),
              const SizedBox(width: 16),
              Expanded(child: widgets[1]),
              const SizedBox(width: 16),
              Expanded(child: widgets[2]),
              const SizedBox(width: 16),
              Expanded(child: widgets[3]),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: widgets[0]),
                  const SizedBox(width: 16),
                  Expanded(child: widgets[1]),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: widgets[2]),
                  const SizedBox(width: 16),
                  Expanded(child: widgets[3]),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}
