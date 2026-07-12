import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../profile/data/profile_local_data_source.dart';
import '../../profile/data/profile_model.dart';
import '../../water/domain/water_repository.dart';
import '../../steps/domain/step_repository.dart';
import '../../sleep/domain/sleep_repository.dart';
import '../../bmi/domain/bmi_repository.dart';

import '../data/health_score_model.dart';
import '../domain/health_score_calculator.dart';
import '../domain/motivation_engine.dart';

/// Provider for calculating and presenting daily health score and 30-day history logs.
class HealthScoreProvider extends ChangeNotifier {
  final ProfileLocalDataSource profileDataSource;
  final WaterRepository waterRepository;
  final StepRepository stepRepository;
  final SleepRepository sleepRepository;
  final BmiRepository bmiRepository;

  HealthScoreProvider({
    required this.profileDataSource,
    required this.waterRepository,
    required this.stepRepository,
    required this.sleepRepository,
    required this.bmiRepository,
  }) {
    // Calculate only today's score immediately for instant UI
    _calculateTodayScore();
    _generateMotivation();
    
    // Defer the expensive 30-day historical calculation to after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateHistoricalScores();
      notifyListeners();
    });
  }

  // ── States ──
  late HealthScoreModel todayScore;
  String motivationMessage = '';
  List<HealthScoreModel> last30DaysScores = [];

  void refreshAll() {
    _calculateTodayScore();
    _calculateHistoricalScores();
    _generateMotivation();
    notifyListeners();
  }

  void _calculateTodayScore() {
    final now = DateTime.now();
    final profile = profileDataSource.getProfile() ?? ProfileModel();

    // Today's metrics
    final todayWater = waterRepository.totalForDate(now).toDouble();
    final stepEntries = stepRepository.getAllEntries();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final todayStepsMatch = stepEntries.where((e) => e.id == todayStr);
    final todaySteps = todayStepsMatch.isNotEmpty ? todayStepsMatch.first.steps.toDouble() : 0.0;

    final sleepRecords = sleepRepository.getAllRecords();
    final todaySleepMatch = sleepRecords.where((r) => DateFormat('yyyy-MM-dd').format(r.wakeTime) == todayStr);
    final todaySleep = todaySleepMatch.isNotEmpty ? todaySleepMatch.first.durationHours : 0.0;

    // Weight progress fraction
    final bmiEntries = bmiRepository.getAllEntries();
    final startingWeight = bmiEntries.isNotEmpty ? bmiEntries.first.weightKg : profile.weightKg;
    final currentWeight = profile.weightKg;
    final targetWeight = profile.targetWeightKg;
    double weightProgress = 1.0;
    if ((startingWeight - targetWeight).abs() > 0.1) {
      weightProgress = ((startingWeight - currentWeight) / (startingWeight - targetWeight)).clamp(0.0, 1.0);
    }

    todayScore = HealthScoreCalculator.calculate(
      date: now,
      waterIntakeMl: todayWater,
      waterGoalMl: profile.waterGoalLiters * 1000.0,
      stepsCount: todaySteps,
      stepGoal: profile.dailyStepGoal.toDouble(),
      sleepHours: todaySleep,
      sleepGoalHours: profile.sleepDurationHours,
      currentBmi: profile.bmi,
      weightProgress: weightProgress,
    );
  }

  void _calculateHistoricalScores() {
    final now = DateTime.now();
    final profile = profileDataSource.getProfile() ?? ProfileModel();
    final stepEntries = stepRepository.getAllEntries();
    final sleepRecords = sleepRepository.getAllRecords();
    final bmiEntries = bmiRepository.getAllEntries();

    final scores = <HealthScoreModel>[];
    for (int i = 0; i < 30; i++) {
      final date = DateTime(now.year, now.month, now.day - (29 - i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final water = waterRepository.totalForDate(date).toDouble();

      final stepsMatch = stepEntries.where((e) => e.id == dateStr);
      final steps = stepsMatch.isNotEmpty ? stepsMatch.first.steps.toDouble() : 0.0;
      final stepGoal = stepsMatch.isNotEmpty ? stepsMatch.first.goal.toDouble() : profile.dailyStepGoal.toDouble();

      final sleepMatch = sleepRecords.where((r) => DateFormat('yyyy-MM-dd').format(r.wakeTime) == dateStr);
      final sleep = sleepMatch.isNotEmpty ? sleepMatch.first.durationHours : 0.0;

      // Find closest BMI / Weight entry around date
      double bmi = profile.bmi;
      double weight = profile.weightKg;
      if (bmiEntries.isNotEmpty) {
        final matches = bmiEntries.where((e) => DateFormat('yyyy-MM-dd').format(e.timestamp) == dateStr);
        if (matches.isNotEmpty) {
          bmi = matches.first.bmiValue;
          weight = matches.first.weightKg;
        }
      }
      final startingWeight = bmiEntries.isNotEmpty ? bmiEntries.first.weightKg : profile.weightKg;
      double weightProgress = 1.0;
      if ((startingWeight - profile.targetWeightKg).abs() > 0.1) {
        weightProgress = ((startingWeight - weight) / (startingWeight - profile.targetWeightKg)).clamp(0.0, 1.0);
      }

      scores.add(HealthScoreCalculator.calculate(
        date: date,
        waterIntakeMl: water,
        waterGoalMl: profile.waterGoalLiters * 1000.0,
        stepsCount: steps,
        stepGoal: stepGoal,
        sleepHours: sleep,
        sleepGoalHours: profile.sleepDurationHours,
        currentBmi: bmi,
        weightProgress: weightProgress,
      ));
    }
    last30DaysScores = scores;
  }

  void _generateMotivation() {
    final profile = profileDataSource.getProfile() ?? ProfileModel();
    final stepEntries = stepRepository.getAllEntries();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayStepsMatch = stepEntries.where((e) => e.id == todayStr);
    final todaySteps = todayStepsMatch.isNotEmpty ? todayStepsMatch.first.steps.toDouble() : 0.0;

    final sleepRecords = sleepRepository.getAllRecords();
    final todaySleepMatch = sleepRecords.where((r) => DateFormat('yyyy-MM-dd').format(r.wakeTime) == todayStr);
    final todaySleep = todaySleepMatch.isNotEmpty ? todaySleepMatch.first.durationHours : 0.0;

    motivationMessage = MotivationEngine.generateMessage(
      waterCurrentMl: waterRepository.totalForDate(DateTime.now()).toDouble(),
      waterGoalMl: profile.waterGoalLiters * 1000.0,
      stepsCurrent: todaySteps,
      stepsGoal: profile.dailyStepGoal.toDouble(),
      sleepHours: todaySleep,
      sleepGoalHours: profile.sleepDurationHours,
    );
  }

  /// Calculates real averages over the last 7 days from raw logged data.
  Map<String, double> getWeeklyAverages() {
    final now = DateTime.now();
    double totalWater = 0;
    double totalSteps = 0;
    double totalSleep = 0;
    double totalScore = 0;

    const daysCount = 7;
    for (int i = 0; i < daysCount; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      totalWater += waterRepository.totalForDate(date).toDouble();

      final stepsMatch = stepRepository.getStepEntry(dateStr);
      if (stepsMatch != null) {
        totalSteps += stepsMatch.steps;
      }

      final sleepRecords = sleepRepository.getAllRecords();
      final sleepMatch = sleepRecords.where((r) => DateFormat('yyyy-MM-dd').format(r.wakeTime) == dateStr);
      if (sleepMatch.isNotEmpty) {
        totalSleep += sleepMatch.first.durationHours;
      }
    }

    final last7Scores = last30DaysScores.length >= 7
        ? last30DaysScores.sublist(last30DaysScores.length - 7)
        : last30DaysScores;
    for (final s in last7Scores) {
      totalScore += s.totalScore;
    }

    return {
      'avgScore': last7Scores.isNotEmpty ? totalScore / last7Scores.length : 0.0,
      'avgWaterL': (totalWater / daysCount) / 1000.0,
      'avgSteps': totalSteps / daysCount,
      'avgSleep': totalSleep / daysCount,
    };
  }
}
