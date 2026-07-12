class MotivationEngine {
  /// Generates a positive, encouraging motivational statement based on daily goal progress gaps.
  static String generateMessage({
    required double waterCurrentMl,
    required double waterGoalMl,
    required double stepsCurrent,
    required double stepsGoal,
    required double sleepHours,
    required double sleepGoalHours,
  }) {
    final waterMet = waterCurrentMl >= waterGoalMl;
    final stepsMet = stepsCurrent >= stepsGoal;
    final sleepMet = sleepHours >= sleepGoalHours;

    if (waterMet && stepsMet && sleepMet) {
      return 'You completed all your goals today. Great job! Keep pushing!';
    }

    // 1. Step target proximity check
    if (!stepsMet && stepsGoal > 0) {
      final stepDiff = stepsGoal - stepsCurrent;
      if (stepDiff <= 3000 && stepDiff > 0) {
        return 'Walk another ${stepDiff.round()} steps to complete today\'s target. You can do it!';
      }
    }

    // 2. Water proximity check
    if (!waterMet && waterGoalMl > 0) {
      final waterDiff = waterGoalMl - waterCurrentMl;
      if (waterDiff <= 1000 && waterDiff > 0) {
        return 'You\'re only ${waterDiff.round()} ml away from your water goal. Time for a glass!';
      }
    }

    // 3. Sleep check
    if (!sleepMet) {
      return 'Prepare to rest: wind down early to meet your 7-9 hours sleep goal tonight.';
    }

    // General encouraging statement
    return 'Small daily changes yield massive wellness outcomes. Keep tracking!';
  }
}
