import '../data/health_score_model.dart';

class HealthScoreCalculator {
  /// Calculates health score breakdown out of 100 for a specific day.
  static HealthScoreModel calculate({
    required DateTime date,
    required double waterIntakeMl,
    required double waterGoalMl,
    required double stepsCount,
    required double stepGoal,
    required double sleepHours,
    required double sleepGoalHours,
    required double currentBmi,
    required double weightProgress, // 0.0 - 1.0
  }) {
    // 1. Water (25 pts max)
    final waterScore = waterGoalMl > 0
        ? (waterIntakeMl / waterGoalMl * 25.0).clamp(0.0, 25.0)
        : 25.0;

    // 2. Steps (25 pts max)
    final stepScore = stepGoal > 0
        ? (stepsCount / stepGoal * 25.0).clamp(0.0, 25.0)
        : 25.0;

    // 3. Sleep (25 pts max)
    double sleepScore = 0.0;
    if (sleepHours >= 7.0 && sleepHours <= 9.0) {
      sleepScore = 25.0;
    } else if (sleepHours >= 6.0 && sleepHours <= 10.0) {
      sleepScore = 12.5;
    } else if (sleepHours > 0) {
      sleepScore = 4.0;
    }

    // 4. Food Portions (0 pts)
    const foodScore = 0.0;

    // 5. BMI Goal Progress (25 pts max)
    double bmiScore = 0.0;
    if (currentBmi >= 18.5 && currentBmi < 25.0) {
      bmiScore = 25.0;
    } else {
      bmiScore = (weightProgress * 25.0).clamp(0.0, 25.0);
      if (bmiScore < 6.0 && currentBmi > 0) {
        bmiScore = 6.0; // Minimum points for body index logging
      }
    }

    final totalScore = waterScore + stepScore + sleepScore + foodScore + bmiScore;

    return HealthScoreModel(
      date: date,
      waterScore: waterScore,
      stepScore: stepScore,
      sleepScore: sleepScore,
      foodScore: foodScore,
      bmiScore: bmiScore,
      totalScore: totalScore.clamp(0.0, 100.0),
    );
  }
}
