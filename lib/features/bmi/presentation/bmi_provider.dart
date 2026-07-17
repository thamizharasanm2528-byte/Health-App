import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../core/services/app_logger.dart';
import '../../profile/data/profile_local_data_source.dart';
import '../../profile/data/profile_model.dart';
import '../data/bmi_entry.dart';
import '../data/bmi_local_data_source.dart';
import '../domain/bmi_repository.dart';
import '../domain/bmi_calculator.dart';

/// Provider class managing the BMI calculation, history, recommendations, and weight goal tracking.
class BmiProvider extends ChangeNotifier {
  final BmiRepository _repository;
  final ProfileLocalDataSource _profileDataSource;

  BmiProvider(this._repository, this._profileDataSource) {
    _loadProfile();
    _loadHistory();
    _sanitizeHistory();
  }

  void _sanitizeHistory() {
    if (!_profileDataSource.hasProfile()) {
      try {
        final box = Hive.box<BMIEntry>(BmiLocalDataSource.boxName);
        box.clear();
      } catch (e, st) {
        AppLogger.error('BmiProvider._sanitizeHistory (clear box)', e, st);
      }
      _history = [];
      notifyListeners();
    }
  }

  // ── Inputs & Profile state ──────────────────────────────────────────

  double _heightCm = 170.0;
  double get heightCm => _heightCm;

  double _weightKg = 70.0;
  double get weightKg => _weightKg;

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  void _loadProfile() {
    _profile = _profileDataSource.getProfile();
    if (_profile != null) {
      _heightCm = _profile!.heightCm;
      _weightKg = _profile!.weightKg;
    }
  }

  // ── Calculation ──────────────────────────────────────────────────────

  /// Calculates BMI value = weight(kg) / height(m)^2.
  double get bmiValue => BmiCalculator.calculateBmi(_weightKg, _heightCm);

  /// Categorizes the BMI score.
  String get bmiCategory => BmiCalculator.getCategory(bmiValue);

  /// Calculates the healthy weight range for the current height (BMI 18.5 to 24.9).
  String get healthyWeightRange {
    if (_heightCm <= 0) return '--';
    return '${healthyWeightMin.toStringAsFixed(1)}–${healthyWeightMax.toStringAsFixed(1)} kg';
  }

  /// Calculates the minimum healthy weight limit.
  double get healthyWeightMin => BmiCalculator.healthyWeightMin(_heightCm);

  /// Calculates the maximum healthy weight limit.
  double get healthyWeightMax => BmiCalculator.healthyWeightMax(_heightCm);

  /// Updates input values in real-time.
  void updateHeight(double height) {
    _heightCm = height;
    notifyListeners();
  }

  void updateWeight(double weight) {
    _weightKg = weight;
    notifyListeners();
  }

  // ── Weight Goal Stats ───────────────────────────────────────────────

  double get currentWeight => _profile?.weightKg ?? _weightKg;

  double get recommendedBestWeight {
    if (_heightCm <= 0) return 70.0;
    final heightM = _heightCm / 100;
    return 21.7 * heightM * heightM; // Midpoint of normal range
  }

  double get targetWeight {
    return _profile?.targetWeightKg ?? recommendedBestWeight;
  }

  double get weightDifference => (currentWeight - targetWeight).abs();

  /// Estimated progress percentage toward target weight.
  /// Uses starting weight from first logged BMIEntry or profile weight as baseline.
  double get weightGoalProgress {
    if (_profile == null) return 0.0;
    final baselineWeight = _history.isNotEmpty ? _history.last.weightKg : currentWeight;
    final target = targetWeight;
    final current = currentWeight;

    if ((baselineWeight - target).abs() < 0.1) return 1.0;

    // Progress fraction: how close current is to target relative to starting weight
    final progress = (baselineWeight - current) / (baselineWeight - target);
    return progress.clamp(0.0, 1.0);
  }

  /// Helper describing weight goal direction (e.g. Lose weight, Gain weight).
  String get weightGoalMessage {
    final diff = currentWeight - targetWeight;
    if (diff.abs() < 0.1) return 'Goal weight achieved! Perfect maintenance.';
    if (diff > 0) return 'Lose ${diff.toStringAsFixed(1)} kg to reach your target.';
    return 'Gain ${diff.abs().toStringAsFixed(1)} kg to reach your target.';
  }

  /// Updates the target weight in the profile.
  Future<void> updateTargetWeight(double newTarget) async {
    if (_profile != null) {
      _profile!.targetWeightKg = newTarget;
      await _profileDataSource.saveProfile(_profile!);
      notifyListeners();
    }
  }

  // ── Calculation History ──────────────────────────────────────────────

  List<BMIEntry> _history = [];
  List<BMIEntry> get history => List.unmodifiable(_history);

  void _loadHistory() {
    _history = _repository.getAllEntries();
  }

  /// Computes and saves the current BMI as a history log entry.
  /// Overwrites the entry if one was already saved today (same date).
  Future<void> saveCurrentBmi() async {
    final now = DateTime.now();
    BMIEntry? existingTodayEntry;
    for (final e in _history) {
      if (e.timestamp.year == now.year &&
          e.timestamp.month == now.month &&
          e.timestamp.day == now.day) {
        existingTodayEntry = e;
        break;
      }
    }

    if (existingTodayEntry != null) {
      final updatedEntry = BMIEntry(
        id: existingTodayEntry.id,
        heightCm: _heightCm,
        weightKg: _weightKg,
        bmiValue: bmiValue,
        category: bmiCategory,
        timestamp: now,
      );
      await _repository.saveBMIEntry(updatedEntry);
    } else {
      final entry = BMIEntry.create(
        heightCm: _heightCm,
        weightKg: _weightKg,
        bmiValue: bmiValue,
        category: bmiCategory,
      );
      await _repository.saveBMIEntry(entry);
    }

    // Also update current height and weight inside user Profile
    if (_profile != null) {
      _profile!.heightCm = _heightCm;
      _profile!.weightKg = _weightKg;
      await _profileDataSource.saveProfile(_profile!);
    }

    _loadHistory();
    _loadProfile();
    notifyListeners();
  }

  /// Deletes a logged entry from history.
  ///
  /// Removes the entry from the in-memory list first (synchronous, instant UI
  /// update), then persists the deletion to Hive in the background.
  Future<void> deleteBmiLog(String id) async {
    // 1. Remove from in-memory list immediately
    _history.removeWhere((e) => e.id == id);
    // 2. Notify listeners so the UI rebuilds without this entry
    notifyListeners();
    // 3. Persist deletion to Hive
    await _repository.deleteBMIEntry(id);
  }

  /// Reloads profile and history from local storage.
  void refreshAll() {
    _loadProfile();
    _loadHistory();
    notifyListeners();
  }
}
