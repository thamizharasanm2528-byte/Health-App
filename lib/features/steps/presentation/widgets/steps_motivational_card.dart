import 'package:flutter/material.dart';
import '../../../../shared/widgets/common_card.dart';

class StepsMotivationalCard extends StatelessWidget {
  final int steps;

  const StepsMotivationalCard({
    super.key,
    required this.steps,
  });

  String _getMotivationalMessage(int steps) {
    if (steps < 3000) {
      return "Every step is a step closer to your fitness goals! Let's get moving. 🚶‍♂️";
    } else if (steps < 7000) {
      return "Great progress! You are on your way to meeting today's target. Keep pushing! 🚀";
    } else if (steps < 10000) {
      return "Amazing! Almost there. Just a little more walk to hit the goal! ⚡";
    } else {
      return "Outstanding! You've crushed today's step goal. Outstanding achievement! 🏆";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CommonCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _getMotivationalMessage(steps),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
