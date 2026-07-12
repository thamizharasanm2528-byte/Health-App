/// Health Companion — Route Names
///
/// Centralised string constants for every named route in the app.
/// Using a single source of truth prevents typos and makes
/// refactoring straightforward.
///
/// Usage:
/// ```dart
/// Navigator.pushNamed(context, RouteNames.dashboard);
/// ```
abstract final class RouteNames {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String profileSetup = '/profile-setup';
  static const String dashboard = '/dashboard';
  static const String water = '/water';
  static const String steps = '/steps';
  static const String bmi = '/bmi';
  static const String sleep = '/sleep';
  static const String settings = '/settings';
  static const String healthScore = '/health-score';
  static const String alarm = '/alarm';
  static const String alarmAlert = '/alarm-alert';
  static const String reminderSettings = '/reminder-settings';
  static const String about = '/about';
  static const String licenses = '/licenses';
}
