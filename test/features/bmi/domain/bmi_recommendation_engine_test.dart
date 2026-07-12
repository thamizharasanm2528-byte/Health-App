import 'package:flutter_test/flutter_test.dart';
import 'package:health_companion/features/bmi/domain/bmi_recommendation_engine.dart';

void main() {
  group('BmiRecommendationEngine Unit Tests', () {
    test('Underweight category returns underweight recommendations', () {
      final tips = BmiRecommendationEngine.getRecommendations('underweight');
      
      // Verification: Should contain 5 underweight tips starting with avocado
      expect(tips.length, 5);
      expect(tips[0].icon, '🥑');
      expect(tips[0].description, contains('Increase nutritious calorie intake'));
    });

    test('Healthy category returns healthy recommendations', () {
      final tips = BmiRecommendationEngine.getRecommendations('healthy');
      
      // Verification: Should contain 5 healthy tips starting with scale
      expect(tips.length, 5);
      expect(tips[0].icon, '⚖️');
      expect(tips[0].description, contains('maintain your current weight'));
    });

    test('Overweight category returns overweight recommendations', () {
      final tips = BmiRecommendationEngine.getRecommendations('overweight');
      
      // Verification: Should contain 5 overweight tips starting with walking
      expect(tips.length, 5);
      expect(tips[0].icon, '🚶');
      expect(tips[0].description, contains('Increase physical activity'));
    });

    test('Obese category returns obese recommendations', () {
      final tips = BmiRecommendationEngine.getRecommendations('obese');
      
      // Verification: Should contain 6 obese tips starting with walking
      expect(tips.length, 6);
      expect(tips[0].icon, '🚶');
      expect(tips[0].description, contains('Gradually increase physical activity'));
    });

    test('Category lookups are case-insensitive', () {
      final tipsLower = BmiRecommendationEngine.getRecommendations('healthy');
      final tipsUpper = BmiRecommendationEngine.getRecommendations('HEALTHY');
      final tipsMixed = BmiRecommendationEngine.getRecommendations('HeAlThY');

      expect(tipsLower.length, 5);
      expect(tipsUpper.length, 5);
      expect(tipsMixed.length, 5);
      expect(tipsUpper[0].description, tipsLower[0].description);
      expect(tipsMixed[0].description, tipsLower[0].description);
    });

    test('Unrecognized category returns default recommendation tip', () {
      final tips = BmiRecommendationEngine.getRecommendations('unknown_category');

      // Verification: Should fallback to single default tip with star icon
      expect(tips.length, 1);
      expect(tips[0].icon, '✨');
      expect(tips[0].description, 'Maintain a active lifestyle, eat clean foods, and sleep well.');
    });
  });
}
