import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/selectable_card.dart';
import '../profile_provider.dart';

/// Step 4 — Activity Level
///
/// Presents selectable cards for 4 activity levels.
class StepActivityLevel extends StatelessWidget {
  const StepActivityLevel({super.key});

  static const _levels = [
    _ActivityOption(
      label: 'Sedentary',
      subtitle: 'Little or no exercise',
      icon: Icons.weekend_rounded,
    ),
    _ActivityOption(
      label: 'Lightly Active',
      subtitle: 'Light exercise 1–3 days/week',
      icon: Icons.directions_walk_rounded,
    ),
    _ActivityOption(
      label: 'Moderately Active',
      subtitle: 'Moderate exercise 3–5 days/week',
      icon: Icons.directions_run_rounded,
    ),
    _ActivityOption(
      label: 'Very Active',
      subtitle: 'Hard exercise 6–7 days/week',
      icon: Icons.fitness_center_rounded,
    ),
  ];

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
            'Activity Level',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How active are you on a typical day?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          ...List.generate(_levels.length, (i) {
            final option = _levels[i];
            final isSelected = provider.activityLevel == option.label;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SelectableCard(
                isSelected: isSelected,
                onTap: () => provider.setActivityLevel(option.label),
                child: Row(
                  children: [
                    Icon(
                      option.icon,
                      size: 28,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option.subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ActivityOption {
  final String label;
  final String subtitle;
  final IconData icon;
  const _ActivityOption({
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}
