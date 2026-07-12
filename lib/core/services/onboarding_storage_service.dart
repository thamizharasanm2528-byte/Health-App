import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting onboarding completion status.
///
/// Uses both Hive (synchronous reads on splash) and SharedPreferences
/// (backward compatibility) to store onboarding completion flag.
class OnboardingStorageService {
  static const _key = 'onboarding_completed';

  /// Returns `true` if the user has already completed onboarding.
  /// Prefers synchronous Hive check, falls back to SharedPreferences.
  static Future<bool> isOnboardingCompleted() async {
    try {
      final box = Hive.box('app_state');
      final hiveResult = box.get(_key, defaultValue: false) as bool;
      if (hiveResult) return true;
    } catch (_) {}
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Marks onboarding as completed in both Hive and SharedPreferences.
  static Future<void> setOnboardingCompleted() async {
    try {
      final box = Hive.box('app_state');
      await box.put(_key, true);
    } catch (_) {}
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
