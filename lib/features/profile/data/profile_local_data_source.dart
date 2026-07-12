import 'package:hive/hive.dart';

import 'profile_model.dart';

/// Hive-backed local data source for [ProfileModel].
///
/// Operates on a single Hive box named [boxName]. The profile
/// is stored at key `0` since there is only one active profile.
class ProfileLocalDataSource {
  /// Hive box name for profile storage.
  static const String boxName = 'profile_box';

  /// Saves or updates the user profile.
  Future<void> saveProfile(ProfileModel profile) async {
    final box = Hive.box<ProfileModel>(boxName);
    await box.put(0, profile);
  }

  /// Returns the saved profile, or `null` if none exists.
  ProfileModel? getProfile() {
    final box = Hive.box<ProfileModel>(boxName);
    return box.get(0);
  }

  /// Returns `true` if a profile has been saved.
  bool hasProfile() {
    final box = Hive.box<ProfileModel>(boxName);
    return box.containsKey(0);
  }
}
