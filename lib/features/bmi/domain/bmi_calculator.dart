/// Pure helper class managing BMI math, categorization, and healthy weight limits.
class BmiCalculator {
  /// Calculates BMI value = weight(kg) / height(m)^2.
  static double calculateBmi(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0.0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Categorizes the BMI score.
  static String getCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Healthy';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Calculates the minimum healthy weight limit (BMI 18.5).
  static double healthyWeightMin(double heightCm) {
    if (heightCm <= 0) return 0.0;
    final heightM = heightCm / 100;
    return 18.5 * heightM * heightM;
  }

  /// Calculates the maximum healthy weight limit (BMI 24.9).
  static double healthyWeightMax(double heightCm) {
    if (heightCm <= 0) return 0.0;
    final heightM = heightCm / 100;
    return 24.9 * heightM * heightM;
  }
}
