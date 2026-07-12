class HealthScoreModel {
  final DateTime date;
  final double waterScore; // max 20
  final double stepScore;  // max 20
  final double sleepScore; // max 20
  final double foodScore;  // max 20
  final double bmiScore;   // max 20
  final double totalScore; // max 100

  const HealthScoreModel({
    required this.date,
    required this.waterScore,
    required this.stepScore,
    required this.sleepScore,
    required this.foodScore,
    required this.bmiScore,
    required this.totalScore,
  });

  String get level {
    if (totalScore >= 90) return 'Excellent';
    if (totalScore >= 75) return 'Very Good';
    if (totalScore >= 60) return 'Good';
    if (totalScore >= 40) return 'Needs Improvement';
    return 'Poor';
  }

  String get message {
    if (totalScore >= 90) {
      return 'Outstanding! You are maintaining an elite lifestyle. Keep it up!';
    } else if (totalScore >= 75) {
      return 'Great job! Most of your core healthy habits are perfectly on track.';
    } else if (totalScore >= 60) {
      return 'Good progress. A few consistent tweaks can elevate your daily wellness.';
    } else if (totalScore >= 40) {
      return 'Solid effort, but some goals are being missed. Try scheduling hydration and walking.';
    } else {
      return 'Wellness metrics are currently low. Establish small daily habits to jumpstart progress!';
    }
  }
}
