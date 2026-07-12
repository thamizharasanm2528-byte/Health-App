import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profile_provider.dart';

/// Step 8 — Summary
///
/// Displays a complete read-only summary of all profile data
/// collected across the previous steps.
class StepSummary extends StatelessWidget {
  const StepSummary({super.key});

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
            'Profile Summary',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your information before finishing.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          // ── Summary card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                _SummaryRow(label: 'Name', value: provider.name),
                _SummaryRow(label: 'Age', value: '${provider.age} years'),
                _SummaryRow(
                  label: 'Height',
                  value: '${provider.heightCm.toStringAsFixed(0)} cm',
                ),
                _SummaryRow(
                  label: 'Weight',
                  value: '${provider.weightKg.toStringAsFixed(0)} kg',
                ),
                _SummaryRow(
                  label: 'BMI',
                  value:
                      '${provider.bmi.toStringAsFixed(1)} (${provider.bmiCategory})',
                ),
                const Divider(height: 24),
                _SummaryRow(
                  label: 'Activity',
                  value: provider.activityLevel,
                ),
                _SummaryRow(
                  label: 'Water Goal',
                  value: '${provider.waterGoalLiters.toStringAsFixed(1)}L / day',
                ),
                _SummaryRow(
                  label: 'Step Goal',
                  value: '${provider.dailyStepGoal} steps / day',
                ),
                const Divider(height: 24),
                _SummaryRow(
                  label: 'Bedtime',
                  value: provider.bedtimeFormatted,
                ),
                _SummaryRow(
                  label: 'Wake Time',
                  value: provider.wakeTimeFormatted,
                ),
                _SummaryRow(
                  label: 'Sleep',
                  value:
                      '${provider.sleepDurationHours.toStringAsFixed(1)} hours',
                ),

              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Reassurance text ──
          Center(
            child: Text(
              'You can update this later in Settings.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Single row inside the summary card.
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
