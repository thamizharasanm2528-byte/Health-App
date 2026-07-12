import 'package:flutter_test/flutter_test.dart';
import 'package:health_companion/features/health_score/domain/motivation_engine.dart';

void main() {
  group('MotivationEngine Unit Tests', () {
    test('All goals met returns all-goals-completed statement', () {
      final msg = MotivationEngine.generateMessage(
        waterCurrentMl: 3000,
        waterGoalMl: 3000,
        stepsCurrent: 10000,
        stepsGoal: 10000,
        sleepHours: 8.0,
        sleepGoalHours: 8.0,
      );

      // Verification: All criteria met -> returns "You completed all your goals today. Great job! Keep pushing!"
      expect(msg, 'You completed all your goals today. Great job! Keep pushing!');
    });

    test('Steps unmet but within 3000 returns steps proximity warning message', () {
      final msg = MotivationEngine.generateMessage(
        waterCurrentMl: 3000,
        waterGoalMl: 3000,
        stepsCurrent: 8000,
        stepsGoal: 10000,
        sleepHours: 8.0,
        sleepGoalHours: 8.0,
      );

      // Calculations:
      // stepsGoal = 10000, stepsCurrent = 8000 -> stepDiff = 2000.
      // Since 2000 <= 3000 and > 0, returns proximity notification.
      expect(msg, 'Walk another 2000 steps to complete today\'s target. You can do it!');
    });

    test('Steps unmet and > 3000, but water unmet and within 1000 ml returns water proximity warning', () {
      final msg = MotivationEngine.generateMessage(
        waterCurrentMl: 2500,
        waterGoalMl: 3000,
        stepsCurrent: 5000,
        stepsGoal: 10000,
        sleepHours: 8.0,
        sleepGoalHours: 8.0,
      );

      // Calculations:
      // stepDiff = 5000 > 3000 (proximity check skipped)
      // waterDiff = 500. Since 500 <= 1000 and > 0, returns water proximity notification.
      expect(msg, 'You\'re only 500 ml away from your water goal. Time for a glass!');
    });

    test('Steps unmet > 3000, water unmet > 1000, and sleep unmet returns sleep warning message', () {
      final msg = MotivationEngine.generateMessage(
        waterCurrentMl: 1000,
        waterGoalMl: 3000,
        stepsCurrent: 5000,
        stepsGoal: 10000,
        sleepHours: 6.0,
        sleepGoalHours: 8.0,
      );

      // Calculations:
      // stepDiff = 5000 > 3000
      // waterDiff = 2000 > 1000
      // sleepHours = 6.0 < sleepGoalHours = 8.0 -> sleepMet is false.
      // Falls through to sleep warning.
      expect(msg, 'Prepare to rest: wind down early to meet your 7-9 hours sleep goal tonight.');
    });

    test('Steps and water unmet beyond boundaries, but sleep met returns general wellness message', () {
      final msg = MotivationEngine.generateMessage(
        waterCurrentMl: 1000,
        waterGoalMl: 3000,
        stepsCurrent: 5000,
        stepsGoal: 10000,
        sleepHours: 8.0,
        sleepGoalHours: 8.0,
      );

      // Calculations:
      // stepDiff = 5000 > 3000
      // waterDiff = 2000 > 1000
      // sleepMet = true.
      // Falls through to general fallback string.
      expect(msg, 'Small daily changes yield massive wellness outcomes. Keep tracking!');
    });

    test('Zero goals handles division safely and returns met or general statements', () {
      final msg = MotivationEngine.generateMessage(
        waterCurrentMl: 0,
        waterGoalMl: 0,
        stepsCurrent: 0,
        stepsGoal: 0,
        sleepHours: 0,
        sleepGoalHours: 0,
      );

      // Calculations:
      // goals are 0.0 -> all met checks return true (current >= goal holds true for 0 >= 0).
      // Returns "You completed all your goals today. Great job! Keep pushing!"
      expect(msg, 'You completed all your goals today. Great job! Keep pushing!');
    });
  });
}
