import 'package:flutter/material.dart';

import '../data/settings_repository.dart';

class UnitsProvider extends ChangeNotifier {
  final SettingsRepository _repository;

  UnitsProvider(this._repository);

  // ── Weight ──
  String get weightUnit => _repository.getSettings().weightUnit;

  double convertWeight(double kg) {
    if (weightUnit == 'lbs') {
      return kg * 2.20462;
    }
    return kg;
  }

  double convertWeightToKg(double val) {
    if (weightUnit == 'lbs') {
      return val / 2.20462;
    }
    return val;
  }

  String formatWeight(double kg) {
    final val = convertWeight(kg);
    return '${val.toStringAsFixed(1)} $weightUnit';
  }

  // ── Height ──
  String get heightUnit => _repository.getSettings().heightUnit;

  String formatHeight(double cm) {
    if (heightUnit == 'ft') {
      final totalInches = cm * 0.393701;
      final feet = totalInches ~/ 12;
      final inches = (totalInches % 12).round();
      return "$feet'$inches\"";
    }
    return '${cm.toStringAsFixed(0)} cm';
  }

  double convertHeightToCm(double val, {double? inches}) {
    if (heightUnit == 'ft') {
      final totalInches = (val * 12) + (inches ?? 0);
      return totalInches / 0.393701;
    }
    return val;
  }

  // ── Water ──
  String get waterUnit => _repository.getSettings().waterUnit;

  double convertWater(double ml) {
    if (waterUnit == 'liters') {
      return ml / 1000.0;
    } else if (waterUnit == 'oz') {
      return ml * 0.033814;
    }
    return ml;
  }

  double convertWaterToMl(double val) {
    if (waterUnit == 'liters') {
      return val * 1000.0;
    } else if (waterUnit == 'oz') {
      return val / 0.033814;
    }
    return val;
  }

  String formatWater(double ml) {
    final val = convertWater(ml);
    if (waterUnit == 'liters') {
      return '${val.toStringAsFixed(2)} L';
    } else if (waterUnit == 'oz') {
      return '${val.toStringAsFixed(1)} fl oz';
    }
    return '${ml.toStringAsFixed(0)} ml';
  }

  // ── Unit selection updates ──
  Future<void> setWeightUnit(String unit) async {
    final settings = _repository.getSettings();
    settings.weightUnit = unit;
    await _repository.saveSettings(settings);
    notifyListeners();
  }

  Future<void> setHeightUnit(String unit) async {
    final settings = _repository.getSettings();
    settings.heightUnit = unit;
    await _repository.saveSettings(settings);
    notifyListeners();
  }

  Future<void> setWaterUnit(String unit) async {
    final settings = _repository.getSettings();
    settings.waterUnit = unit;
    await _repository.saveSettings(settings);
    notifyListeners();
  }
}
