import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profile_provider.dart';

/// Step 6 — Sleep Schedule
///
/// Lets the user pick bedtime and wake-up time using
/// Material time pickers. Displays expected sleep duration.
class StepSleepSchedule extends StatelessWidget {
  const StepSleepSchedule({super.key});

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
            'Sleep Schedule',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A consistent sleep schedule improves your health.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 32),

          // ── Time pickers row ──
          Row(
            children: [
              Expanded(
                child: _TimeTile(
                  label: 'Bedtime',
                  icon: Icons.bedtime_rounded,
                  formattedTime: provider.bedtimeFormatted,
                  onTap: () => _pickTime(
                    context,
                    provider.bedtimeMinutes,
                    (mins) => provider.setBedtime(mins),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TimeTile(
                  label: 'Wake Time',
                  icon: Icons.wb_sunny_rounded,
                  formattedTime: provider.wakeTimeFormatted,
                  onTap: () => _pickTime(
                    context,
                    provider.wakeTimeMinutes,
                    (mins) => provider.setWakeTime(mins),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Expected sleep duration ──
          _SleepDurationCard(hours: provider.sleepDurationHours),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    int currentMinutes,
    ValueChanged<int> onPicked,
  ) async {
    final initial = TimeOfDay(
      hour: currentMinutes ~/ 60,
      minute: currentMinutes % 60,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) {
        return MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onPicked(picked.hour * 60 + picked.minute);
    }
  }
}

/// Tappable tile showing a labelled time value.
class _TimeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String formattedTime;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.icon,
    required this.formattedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.primary),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedTime,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card displaying expected sleep duration in hours.
class _SleepDurationCard extends StatelessWidget {
  final double hours;
  const _SleepDurationCard({required this.hours});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wholePart = hours.floor();
    final minutePart = ((hours - wholePart) * 60).round();

    String durationText;
    if (minutePart == 0) {
      durationText = '$wholePart Hours';
    } else {
      durationText = '$wholePart Hr $minutePart Min';
    }

    final isGood = hours >= 7 && hours <= 9;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isGood
                ? theme.colorScheme.primary
                : const Color(0xFFFFA726))
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isGood
                  ? theme.colorScheme.primary
                  : const Color(0xFFFFA726))
              .withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.nights_stay_rounded,
            size: 32,
            color: isGood
                ? theme.colorScheme.primary
                : const Color(0xFFFFA726),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expected Sleep',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  durationText,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isGood
                        ? theme.colorScheme.primary
                        : const Color(0xFFFFA726),
                  ),
                ),
              ],
            ),
          ),
          if (isGood)
            Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
        ],
      ),
    );
  }
}
