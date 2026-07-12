import 'package:hive/hive.dart';

import 'settings_model.dart';
import 'settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String boxName = 'settings_box';

  @override
  SettingsModel getSettings() {
    final box = Hive.box<SettingsModel>(boxName);
    return box.get('app_settings') ?? SettingsModel();
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    final box = Hive.box<SettingsModel>(boxName);
    await box.put('app_settings', settings);
  }
}
