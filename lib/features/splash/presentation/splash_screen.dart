import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../core/routing/route_names.dart';
import '../../profile/data/profile_local_data_source.dart';
import 'widgets/splash_background.dart';
import 'widgets/splash_logo.dart';
import 'widgets/splash_text_group.dart';

/// Splash Screen
///
/// Premium launch screen with staggered fade-in & scale animations.
/// Displays the app logo, title, and tagline on a themed background,
/// then auto-navigates after [_splashDuration]:
/// - If first launch → Onboarding
/// - If onboarding done but no profile → Profile Setup
/// - If profile exists → Dashboard
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// Total splash display time before navigation fires.
  static const _splashDuration = Duration(milliseconds: 1500);

  late final AnimationController _controller;

  // ── Staggered intervals ─────────────────────────────────────────────

  /// Logo: 0% → 50% of animation timeline.
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  /// Title: 20% → 60%.
  late final Animation<double> _titleFade;
  late final Animation<double> _titleSlide;

  /// Tagline: 40% → 80%.
  late final Animation<double> _taglineFade;
  late final Animation<double> _taglineSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // ── Logo animations ──
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.50, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutBack),
      ),
    );

    // ── Title animations ──
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.60, curve: Curves.easeOut),
    );
    _titleSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    // ── Tagline animations ──
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.40, 0.80, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    // Start animations.
    _controller.forward();

    // Schedule navigation after splash delay.
    _scheduleNavigation();
  }

  Future<void> _scheduleNavigation() async {
    // Use synchronous Hive check for onboarding status — avoids async SharedPreferences wait.
    bool onboardingDone = false;
    try {
      final box = Hive.box('app_state');
      onboardingDone = box.get('onboarding_completed', defaultValue: false) as bool;
    } catch (_) {}
    final profileExists = ProfileLocalDataSource().hasProfile();

    // Ensure the splash shows for at least the full duration.
    await Future.delayed(_splashDuration);

    if (!mounted) return;

    String route;
    if (!onboardingDone) {
      route = RouteNames.onboarding;
    } else if (!profileExists) {
      route = RouteNames.profileSetup;
    } else {
      route = RouteNames.dashboard;
    }

    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Animated Logo ──
              SplashLogo(
                fadeAnimation: _logoFade,
                scaleAnimation: _logoScale,
              ),

              const SizedBox(height: 32),

              // ── Animated Title & Tagline ──
              SplashTextGroup(
                titleFade: _titleFade,
                titleSlide: _titleSlide,
                taglineFade: _taglineFade,
                taglineSlide: _taglineSlide,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
