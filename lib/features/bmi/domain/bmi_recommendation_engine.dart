/// Recommended tip item containing advice description and associated icon/emoji.
class HealthTip {
  final String description;
  final String icon;

  const HealthTip({required this.description, required this.icon});
}

/// Helper engine generating personalized wellness advice based on BMI category.
class BmiRecommendationEngine {
  /// Returns a list of tailored recommendations depending on category.
  static List<HealthTip> getRecommendations(String category) {
    switch (category.toLowerCase()) {
      case 'underweight':
        return const [
          HealthTip(
            description: 'Increase nutritious calorie intake with healthy fats and complex carbs.',
            icon: '🥑',
          ),
          HealthTip(
            description: 'Focus on strength training to build healthy muscle mass.',
            icon: '💪',
          ),
          HealthTip(
            description: 'Incorporate protein-rich foods like eggs, chicken, fish, tofu, and nuts.',
            icon: '🍗',
          ),
          HealthTip(
            description: 'Stay hydrated with at least 2–3L of water daily.',
            icon: '💧',
          ),
          HealthTip(
            description: 'Prioritize sleeping at least 8 hours nightly to aid recovery.',
            icon: '😴',
          ),
        ];

      case 'healthy':
        return const [
          HealthTip(
            description: 'Aim to maintain your current weight with healthy lifestyle choices.',
            icon: '⚖️',
          ),
          HealthTip(
            description: 'Consume a balanced diet rich in whole foods, vegetables, and lean proteins.',
            icon: '🥗',
          ),
          HealthTip(
            description: 'Exercise regularly, combining cardio with strength training.',
            icon: '🏃',
          ),
          HealthTip(
            description: 'Drink 2–3L of water daily to support metabolic functions.',
            icon: '💧',
          ),
          HealthTip(
            description: 'Prioritize a regular sleep schedule of 7–9 hours.',
            icon: '😴',
          ),
        ];

      case 'overweight':
        return const [
          HealthTip(
            description: 'Increase physical activity, starting with daily brisk walking.',
            icon: '🚶',
          ),
          HealthTip(
            description: 'Reduce sugary drinks, soda, juices, and sweetened coffees.',
            icon: '🚫',
          ),
          HealthTip(
            description: 'Add more vegetables and high-fiber foods to your meals.',
            icon: '🥦',
          ),
          HealthTip(
            description: 'Drink at least 3L of water daily to support digestion and satiety.',
            icon: '💧',
          ),
          HealthTip(
            description: 'Commit to 30–45 minutes of moderate exercise 4–5 times a week.',
            icon: '🚴',
          ),
        ];

      case 'obese':
        return const [
          HealthTip(
            description: 'Gradually increase physical activity, focusing on joint-friendly routines.',
            icon: '🚶',
          ),
          HealthTip(
            description: 'Structure balanced meals with controlled portion sizes.',
            icon: '🍽️',
          ),
          HealthTip(
            description: 'Reduce processed foods, fast food, and refined sugars.',
            icon: '🍔',
          ),
          HealthTip(
            description: 'Drink 3L of water daily to stay hydrated and support weight management.',
            icon: '💧',
          ),
          HealthTip(
            description: 'Aim for a consistent 7–9 hours of sleep to regulate hunger hormones.',
            icon: '😴',
          ),
          HealthTip(
            description: 'We highly suggest consulting a healthcare professional for personalized medical and fitness advice.',
            icon: '🩺',
          ),
        ];

      default:
        return const [
          HealthTip(
            description: 'Maintain a active lifestyle, eat clean foods, and sleep well.',
            icon: '✨',
          ),
        ];
    }
  }
}
