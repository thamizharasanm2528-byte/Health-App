import 'package:flutter/material.dart';

import '../data/profile_model.dart';
import '../domain/profile_repository.dart';

/// State manager for the multi-step profile setup wizard.
///
/// Holds the in-progress [ProfileModel], current step index,
/// form validation state, and delegates persistence to
/// [ProfileRepository].
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider(this._repository);

  // ── Step state ───────────────────────────────────────────────────────

  static const int totalSteps = 7;
  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool get isFirstStep => _currentStep == 0;
  bool get isLastStep => _currentStep == totalSteps - 1;

  // ── Profile data (mutable during setup) ──────────────────────────────

  String _name = '';
  int _age = 0;
  DateTime? _dateOfBirth;
  double _heightCm = 0.0;
  double _weightKg = 0.0;
  String _activityLevel = 'Moderately Active';
  double _waterGoalLiters = 3.0;
  int _dailyStepGoal = 8000;
  int _bedtimeMinutes = 1350; // 22:30
  int _wakeTimeMinutes = 390; // 06:30
  final List<String> _foodPreferences = [];

  // ── Getters ──────────────────────────────────────────────────────────

  String get name => _name;
  int get age => _age;
  DateTime? get dateOfBirth => _dateOfBirth;
  double get heightCm => _heightCm;
  double get weightKg => _weightKg;
  String get activityLevel => _activityLevel;
  double get waterGoalLiters => _waterGoalLiters;
  int get dailyStepGoal => _dailyStepGoal;
  int get bedtimeMinutes => _bedtimeMinutes;
  int get wakeTimeMinutes => _wakeTimeMinutes;
  List<String> get foodPreferences => List.unmodifiable(_foodPreferences);

  // ── Computed ─────────────────────────────────────────────────────────

  double get bmi {
    if (_heightCm <= 0) return 0;
    final hm = _heightCm / 100;
    return _weightKg / (hm * hm);
  }

  String get bmiCategory {
    final v = bmi;
    if (v < 18.5) return 'Underweight';
    if (v < 25) return 'Healthy';
    if (v < 30) return 'Overweight';
    return 'Obese';
  }

  double get sleepDurationHours {
    var diff = _wakeTimeMinutes - _bedtimeMinutes;
    if (diff <= 0) diff += 1440;
    return diff / 60;
  }

  String get bedtimeFormatted => _formatMinutes(_bedtimeMinutes);
  String get wakeTimeFormatted => _formatMinutes(_wakeTimeMinutes);

  String _formatMinutes(int total) {
    final h = total ~/ 60;
    final m = total % 60;
    final p = h >= 12 ? 'PM' : 'AM';
    final dh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$dh:${m.toString().padLeft(2, '0')} $p';
  }

  // ── Setters (notify listeners) ───────────────────────────────────────

  void setName(String v) {
    _name = v;
    notifyListeners();
  }

  void setAge(int v) {
    _age = v;
    notifyListeners();
  }

  void setDateOfBirth(DateTime date) {
    _dateOfBirth = date;
    final now = DateTime.now();
    int age = now.year - date.year;
    if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
      age--;
    }
    _age = age;
    notifyListeners();
  }

  void setHeightCm(double v) {
    _heightCm = v;
    notifyListeners();
  }

  void setWeightKg(double v) {
    _weightKg = v;
    notifyListeners();
  }

  void setActivityLevel(String v) {
    _activityLevel = v;
    notifyListeners();
  }

  void setWaterGoal(double v) {
    _waterGoalLiters = v;
    notifyListeners();
  }

  void setDailyStepGoal(int v) {
    _dailyStepGoal = v;
    notifyListeners();
  }

  void setBedtime(int minutes) {
    _bedtimeMinutes = minutes;
    notifyListeners();
  }

  void setWakeTime(int minutes) {
    _wakeTimeMinutes = minutes;
    notifyListeners();
  }

  void toggleFoodPreference(String item) {
    if (_foodPreferences.contains(item)) {
      _foodPreferences.remove(item);
    } else {
      _foodPreferences.add(item);
    }
    notifyListeners();
  }

  // ── Navigation ───────────────────────────────────────────────────────

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  // ── Validation ───────────────────────────────────────────────────────

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your name';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validateAge(String? v) {
    if (_dateOfBirth == null) return 'Please select Date of Birth';
    if (_age < 10 || _age > 100) return 'Age must be between 10 and 100';
    return null;
  }

  String? validateHeight(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your height';
    final h = double.tryParse(v);
    if (h == null) return 'Enter a valid number';
    if (h < 50 || h > 300) return 'Height must be 50–300 cm';
    return null;
  }

  String? validateWeight(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your weight';
    final w = double.tryParse(v);
    if (w == null) return 'Enter a valid number';
    if (w < 10 || w > 500) return 'Weight must be 10–500 kg';
    return null;
  }

  /// Whether the current step has enough data to proceed.
  bool get canProceed {
    switch (_currentStep) {
      case 0:
        return true; // welcome
      case 1:
        return _name.trim().length >= 2 && _dateOfBirth != null && _age >= 10 && _age <= 100;
      case 2:
        return _heightCm >= 50 && _heightCm <= 300 &&
               _weightKg >= 10 && _weightKg <= 500;
      case 3:
        return _activityLevel.isNotEmpty;
      case 4:
        return true; // goals always have defaults
      case 5:
        return true; // sleep always has defaults
      case 6:
        return true; // summary
      default:
        return false;
    }
  }

  // ── Persistence ──────────────────────────────────────────────────────

  /// Saves the profile to Hive and returns `true` on success.
  Future<bool> saveProfile() async {
    try {
      final profile = ProfileModel(
        name: _name.trim(),
        age: _age,
        dateOfBirth: _dateOfBirth,
        heightCm: _heightCm,
        weightKg: _weightKg,
        activityLevel: _activityLevel,
        waterGoalLiters: _waterGoalLiters,
        dailyStepGoal: _dailyStepGoal,
        bedtimeMinutes: _bedtimeMinutes,
        wakeTimeMinutes: _wakeTimeMinutes,
        foodPreferences: List.from(_foodPreferences),
      );
      await _repository.saveProfile(profile);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
