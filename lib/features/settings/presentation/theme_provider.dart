import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/settings_repository.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingsRepository _repository;

  ThemeProvider(this._repository);

  ThemeMode get themeMode {
    final settings = _repository.getSettings();
    switch (settings.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String get themeModeStr => _repository.getSettings().themeMode;

  Future<void> setThemeMode(String mode) async {
    final settings = _repository.getSettings();
    settings.themeMode = mode;
    await _repository.saveSettings(settings);
    notifyListeners();
  }

  String get accentColor {
    final box = Hive.box<String>('theme_prefs_box');
    return box.get('accent_color') ?? 'green';
  }

  Future<void> setAccentColor(String color) async {
    final box = Hive.box<String>('theme_prefs_box');
    await box.put('accent_color', color);
    notifyListeners();
  }
}
