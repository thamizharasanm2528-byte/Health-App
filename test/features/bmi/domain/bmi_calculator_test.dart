import 'package:flutter_test/flutter_test.dart';
import 'package:health_companion/features/bmi/domain/bmi_calculator.dart';

void main() {
  group('BmiCalculator Unit Tests', () {
    test('calculateBmi returns correct value and guards against height <= 0', () {
      // Calculations:
      // weight = 70.0 kg, height = 175.0 cm (1.75 m)
      // bmi = 70 / (1.75 * 1.75) = 70 / 3.0625 = 22.85714...
      expect(BmiCalculator.calculateBmi(70.0, 175.0), closeTo(22.86, 0.01));
      
      // Verification: height <= 0 returns 0.0
      expect(BmiCalculator.calculateBmi(70.0, 0.0), 0.0);
      expect(BmiCalculator.calculateBmi(70.0, -10.0), 0.0);
    });

    test('getCategory classifies BMI values correctly', () {
      // Underweight: < 18.5
      expect(BmiCalculator.getCategory(18.4), 'Underweight');
      
      // Healthy: >= 18.5 and < 25.0
      expect(BmiCalculator.getCategory(18.5), 'Healthy');
      expect(BmiCalculator.getCategory(24.9), 'Healthy');
      
      // Overweight: >= 25.0 and < 30.0
      expect(BmiCalculator.getCategory(25.0), 'Overweight');
      expect(BmiCalculator.getCategory(29.9), 'Overweight');
      
      // Obese: >= 30.0
      expect(BmiCalculator.getCategory(30.0), 'Obese');
      expect(BmiCalculator.getCategory(35.5), 'Obese');
    });

    test('healthyWeightMin returns correct weight limit and handles height <= 0', () {
      // Calculation:
      // height = 180.0 cm (1.80 m). min = 18.5 * 1.8 * 1.8 = 18.5 * 3.24 = 59.94 kg
      expect(BmiCalculator.healthyWeightMin(180.0), closeTo(59.94, 0.01));
      expect(BmiCalculator.healthyWeightMin(0.0), 0.0);
    });

    test('healthyWeightMax returns correct weight limit and handles height <= 0', () {
      // Calculation:
      // height = 180.0 cm (1.80 m). max = 24.9 * 1.8 * 1.8 = 24.9 * 3.24 = 80.676 kg
      expect(BmiCalculator.healthyWeightMax(180.0), closeTo(80.68, 0.01));
      expect(BmiCalculator.healthyWeightMax(0.0), 0.0);
    });
  });
}
