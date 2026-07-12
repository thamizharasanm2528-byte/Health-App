import 'package:flutter/material.dart';

import '../../features/bmi/presentation/bmi_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/reminder_settings_screen.dart';
import '../../features/sleep/presentation/sleep_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/steps/presentation/steps_screen.dart';
import '../../features/water/presentation/water_screen.dart';
import '../../features/health_score/presentation/health_score_screen.dart';
import '../../features/alarm/presentation/wakeup_alarm_screen.dart';
import '../../features/alarm/presentation/alarm_alert_screen.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/about/presentation/licenses_screen.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

/// Health Companion — App Router
///
/// Centralised route configuration using [onGenerateRoute].
/// Each feature screen is lazily built only when navigated to.
///
/// Unknown routes fall back to a styled 404 page.
abstract final class AppRouter {
  /// Generates routes for [MaterialApp.onGenerateRoute].
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _buildRoute(settings, const SplashScreen());

      case RouteNames.onboarding:
        return _buildFadeRoute(settings, const OnboardingScreen());

      case RouteNames.profileSetup:
        return _buildFadeRoute(settings, const ProfileScreen());

      case RouteNames.dashboard:
        return _buildFadeRoute(settings, const DashboardScreen());

      case RouteNames.water:
        return _buildRoute(settings, const WaterScreen());

      case RouteNames.steps:
        return _buildRoute(settings, const StepsScreen());

      case RouteNames.bmi:
        return _buildRoute(settings, const BmiScreen());

      case RouteNames.sleep:
        return _buildRoute(settings, const SleepScreen());



      case RouteNames.settings:
        return _buildRoute(settings, const SettingsScreen());

      case RouteNames.reminderSettings:
        return _buildRoute(settings, const ReminderSettingsScreen());

      case RouteNames.healthScore:
        return _buildRoute(settings, const HealthScoreScreen());

      case RouteNames.alarm:
        return _buildRoute(settings, const WakeupAlarmScreen());

      case RouteNames.alarmAlert:
        return _buildRoute(settings, const AlarmAlertScreen());

      case RouteNames.about:
        return _buildRoute(settings, const AboutScreen());

      case RouteNames.licenses:
        return _buildRoute(settings, const LicensesScreen());

      default:
        return _buildRoute(
          settings,
          const _NotFoundScreen(),
        );
    }
  }

  /// Helper that wraps a widget in a custom transition [PageRouteBuilder].
  ///
  /// Uses a smooth Fade + slight upward Slide transition (280ms duration).
  static Route<T> _buildRoute<T>(
    RouteSettings settings,
    Widget page,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.of(context).disableAnimations) {
          return child;
        }

        const begin = Offset(0.0, 0.06); // 6% height offset for visual slide
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Helper that wraps a widget in a fade-transition [PageRouteBuilder].
  ///
  /// Used for premium transitions (e.g. splash → onboarding).
  static PageRouteBuilder<T> _buildFadeRoute<T>(
    RouteSettings settings,
    Widget page, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.of(context).disableAnimations) {
          return child;
        }
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

/// Styled 404 fallback shown when an unknown route is pushed.
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_off_rounded,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The route you requested does not exist.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.splash,
                (_) => false,
              ),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
