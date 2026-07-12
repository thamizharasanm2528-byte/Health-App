import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/selection_chip_group.dart';
import '../profile_provider.dart';

/// Step 5 — Daily Goals
///
/// Lets the user pick a daily water goal (litres) and
/// a daily step goal using selection chips.
class StepDailyGoals extends StatelessWidget {
  const StepDailyGoals({super.key});

  static const _waterOptions = [2.0, 2.5, 3.0, 3.5, 4.0];
  static const _stepOptions = [5000, 7000, 8000, 10000, 12000];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProfileProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          Text(
            'Daily Goals',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set targets that match your lifestyle.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 32),

          // ── Water Goal ──
          Row(
            children: [
              Icon(Icons.water_drop_rounded,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Water Goal',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SelectionChipGroup<double>(
            options: _waterOptions,
            selected: {provider.waterGoalLiters},
            labelBuilder: (v) => '${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1)}L',
            onSelected: (v) => provider.setWaterGoal(v),
          ),

          const SizedBox(height: 36),

          // ── Step Goal ──
          Row(
            children: [
              Icon(Icons.directions_walk_rounded,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Daily Step Goal',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SelectionChipGroup<int>(
            options: _stepOptions,
            selected: {provider.dailyStepGoal},
            labelBuilder: (v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K' : v.toString(),
            onSelected: (v) => provider.setDailyStepGoal(v),
          ),
        ],
      ),
    );
  }
}
