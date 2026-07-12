import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';

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
    } catch (e, st) {
      AppLogger.error('OnboardingStorageService.isOnboardingCompleted (Hive read)', e, st);
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Marks onboarding as completed in both Hive and SharedPreferences.
  static Future<void> setOnboardingCompleted() async {
    try {
      final box = Hive.box('app_state');
      await box.put(_key, true);
    } catch (e, st) {
      AppLogger.error('OnboardingStorageService.setOnboardingCompleted (Hive write)', e, st);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
