import '../data/profile_model.dart';

/// Abstract contract for profile persistence operations.
///
/// Implemented by [ProfileRepositoryImpl] in the data layer.
/// Presentation layer depends only on this abstraction.
abstract class ProfileRepository {
  /// Persists the profile locally.
  Future<void> saveProfile(ProfileModel profile);

  /// Returns the saved profile, or `null` if none exists.
  ProfileModel? getProfile();

  /// Whether a profile has been saved previously.
  bool hasProfile();
}
