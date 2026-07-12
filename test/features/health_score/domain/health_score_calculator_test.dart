import 'package:flutter_test/flutter_test.dart';
import 'package:health_companion/features/health_score/domain/health_score_calculator.dart';

void main() {
  group('HealthScoreCalculator Unit Tests', () {
    final testDate = DateTime(2026, 7, 12);

    test('Perfect-score scenario returns 100', () {
      final result = HealthScoreCalculator.calculate(
        date: testDate,
        waterIntakeMl: 3000,
        waterGoalMl: 3000,
        stepsCount: 10000,
        stepGoal: 10000,
        sleepHours: 8.0,
        sleepGoalHours: 8.0,
        currentBmi: 22.0, // healthy BMI range (18.5 - 25.0) yields 25 points
        weightProgress: 1.0,
      );

      // Calculations:
      // Water Score: (3000 / 3000) * 25 = 25.0
      // Step Score: (10000 / 10000) * 25 = 25.0
      // Sleep Score: 8.0 hrs sleep is in [7.0, 9.0] range = 25.0
      // BMI Score: 22.0 is in [18.5, 25.0) range = 25.0
      // Total Score: 25.0 + 25.0 + 25.0 + 25.0 = 100.0
      expect(result.waterScore, 25.0);
      expect(result.stepScore, 25.0);
      expect(result.sleepScore, 25.0);
      expect(result.bmiScore, 25.0);
      expect(result.totalScore, 100.0);
    });

    test('Minimal-score scenario (all inputs zero/unmet) returns 6.0 due to BMI logging fallback', () {
      final result = HealthScoreCalculator.calculate(
        date: testDate,
        waterIntakeMl: 0,
        waterGoalMl: 3000,
        stepsCount: 0,
        stepGoal: 10000,
        sleepHours: 0,
        sleepGoalHours: 8.0,
        currentBmi: 30.0, // Obese BMI, not in healthy range
        weightProgress: 0.0,
      );

      // Calculations:
      // Water Score: (0 / 3000) * 25 = 0.0
      // Step Score: (0 / 10000) * 25 = 0.0
      // Sleep Score: 0.0 hours sleep yields 0.0
      // BMI Score: 30.0 is not healthy, weight progress is 0.0, but currentBmi > 0 yields fallback of 6.0
      // Total Score: 0.0 + 0.0 + 0.0 + 6.0 = 6.0
      expect(result.waterScore, 0.0);
      expect(result.stepScore, 0.0);
      expect(result.sleepScore, 0.0);
      expect(result.bmiScore, 6.0);
      expect(result.totalScore, 6.0);
    });

    test('Zero-goal boundary edge cases resolve to full points (divide-by-zero guards)', () {
      final result = HealthScoreCalculator.calculate(
        date: testDate,
        waterIntakeMl: 0,
        waterGoalMl: 0,
        stepsCount: 0,
        stepGoal: 0,
        sleepHours: 8.0,
        sleepGoalHours: 0.0,
        currentBmi: 22.0,
        weightProgress: 0.0,
      );

      // Calculations:
      // Water Goal is 0.0 -> fallback yields max 25.0 points
      // Step Goal is 0.0 -> fallback yields max 25.0 points
      // Sleep Score: 8.0 hrs sleep -> 25.0 points
      // BMI Score: 22.0 is healthy -> 25.0 points
      // Total Score: 25.0 + 25.0 + 25.0 + 25.0 = 100.0
      expect(result.waterScore, 25.0);
      expect(result.stepScore, 25.0);
      expect(result.totalScore, 100.0);
    });

    test('Partial-progress scenario is hand-calculated correctly', () {
      final result = HealthScoreCalculator.calculate(
        date: testDate,
        waterIntakeMl: 1500,
        waterGoalMl: 3000,
        stepsCount: 4000,
        stepGoal: 10000,
        sleepHours: 6.5,
        sleepGoalHours: 8.0,
        currentBmi: 28.0, // overweight
        weightProgress: 0.40, // 40% progress to weight target
      );

      // Calculations:
      // Water Score: (1500 / 3000) * 25.0 = 12.5
      // Step Score: (4000 / 10000) * 25.0 = 10.0
      // Sleep Score: 6.5 hrs is in [6.0, 10.0] range = 12.5
      // BMI Score: 28.0 is overweight. Progress is 40% -> 0.40 * 25.0 = 10.0. Since 10.0 >= 6.0, no fallback.
      // Total Score: 12.5 + 10.0 + 12.5 + 0.0 (food) + 10.0 = 45.0
      expect(result.waterScore, 12.5);
      expect(result.stepScore, 10.0);
      expect(result.sleepScore, 12.5);
      expect(result.bmiScore, 10.0);
      expect(result.totalScore, 45.0);
    });

    group('Sleep tier boundary evaluations', () {
      test('Sleep at 5.99 hrs returns minimal sleep score (4.0)', () {
        final result = HealthScoreCalculator.calculate(
          date: testDate,
          waterIntakeMl: 0,
          waterGoalMl: 0,
          stepsCount: 0,
          stepGoal: 0,
          sleepHours: 5.99,
          sleepGoalHours: 8.0,
          currentBmi: 0.0,
          weightProgress: 0.0,
        );
        // Calculation: 5.99 > 0 and < 6.0 yields 4.0 points
        expect(result.sleepScore, 4.0);
      });

      test('Sleep at exactly 6.0 hrs returns half sleep score (12.5)', () {
        final result = HealthScoreCalculator.calculate(
          date: testDate,
          waterIntakeMl: 0,
          waterGoalMl: 0,
          stepsCount: 0,
          stepGoal: 0,
          sleepHours: 6.0,
          sleepGoalHours: 8.0,
          currentBmi: 0.0,
          weightProgress: 0.0,
        );
        // Calculation: exactly 6.0 is in [6.0, 10.0] range yields 12.5 points
        expect(result.sleepScore, 12.5);
      });

      test('Sleep at 6.99 hrs returns half sleep score (12.5)', () {
        final result = HealthScoreCalculator.calculate(
          date: testDate,
          waterIntakeMl: 0,
          waterGoalMl: 0,
          stepsCount: 0,
          stepGoal: 0,
          sleepHours: 6.99,
          sleepGoalHours: 8.0,
          currentBmi: 0.0,
          weightProgress: 0.0,
        );
        // Calculation: 6.99 is in [6.0, 10.0] range yields 12.5 points
        expect(result.sleepScore, 12.5);
      });

      test('Sleep at exactly 7.0 hrs returns full sleep score (25.0)', () {
        final result = HealthScoreCalculator.calculate(
          date: testDate,
          waterIntakeMl: 0,
          waterGoalMl: 0,
          stepsCount: 0,
          stepGoal: 0,
          sleepHours: 7.0,
          sleepGoalHours: 8.0,
          currentBmi: 0.0,
          weightProgress: 0.0,
        );
        // Calculation: exactly 7.0 is in [7.0, 9.0] range yields 25.0 points
        expect(result.sleepScore, 25.0);
      });

      test('Sleep at exactly 9.0 hrs returns full sleep score (25.0)', () {
        final result = HealthScoreCalculator.calculate(
          date: testDate,
          waterIntakeMl: 0,
          waterGoalMl: 0,
          stepsCount: 0,
          stepGoal: 0,
          sleepHours: 9.0,
          sleepGoalHours: 8.0,
          currentBmi: 0.0,
          weightProgress: 0.0,
        );
        // Calculation: exactly 9.0 is in [7.0, 9.0] range yields 25.0 points
        expect(result.sleepScore, 25.0);
      });

      test('Sleep at 9.01 hrs returns half sleep score (12.5)', () {
        final result = HealthScoreCalculator.calculate(
          date: testDate,
          waterIntakeMl: 0,
          waterGoalMl: 0,
          stepsCount: 0,
          stepGoal: 0,
          sleepHours: 9.01,
          sleepGoalHours: 8.0,
          currentBmi: 0.0,
          weightProgress: 0.0,
        );
        // Calculation: 9.01 is in [6.0, 10.0] range yields 12.5 points
        expect(result.sleepScore, 12.5);
      });

      test('Sleep at exactly 10.0 hrs returns half sleep score (12.5)', () {
        final result = HealthScoreCalculator.calculate(
          date: testDate,
          waterIntakeMl: 0,
          waterGoalMl: 0,
          stepsCount: 0,
          stepGoal: 0,
          sleepHours: 10.0,
          sleepGoalHours: 8.0,
          currentBmi: 0.0,
          weightProgress: 0.0,
        );
        // Calculation: exactly 10.0 is in [6.0, 10.0] range yields 12.5 points
        expect(result.sleepScore, 12.5);
      });

      test('Sleep at 10.01 hrs returns minimal sleep score (4.0)', () {
        final result = HealthScoreCalculator.calculate(
          date: testDate,
          waterIntakeMl: 0,
          waterGoalMl: 0,
          stepsCount: 0,
          stepGoal: 0,
          sleepHours: 10.01,
          sleepGoalHours: 8.0,
          currentBmi: 0.0,
          weightProgress: 0.0,
        );
        // Calculation: 10.01 > 10.0 yields 4.0 points
        expect(result.sleepScore, 4.0);
      });
    });
  });
}
