import 'settings_model.dart';

abstract interface class SettingsRepository {
  SettingsModel getSettings();
  Future<void> saveSettings(SettingsModel settings);
}
