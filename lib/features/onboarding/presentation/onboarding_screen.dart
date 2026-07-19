import 'package:flutter/material.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/services/onboarding_storage_service.dart';
import '../../../core/services/notifications/notification_service.dart';
import '../../../shared/widgets/page_indicator.dart';
import 'onboarding_content.dart';
import 'widgets/onboarding_page_widget.dart';

/// Onboarding Screen
///
/// A 5-page walkthrough introducing the app's core health-tracking
/// features. Supports swipe gestures, a smooth page indicator,
/// Skip / Next / Get Started buttons, and persists completion
/// status so the flow only appears on first launch.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Entry animation ──────────────────────────────────────────────────

  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));

    _entryController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  // ── Navigation ───────────────────────────────────────────────────────

  bool get _isLastPage => _currentPage == onboardingPages.length - 1;

  void _onNextPressed() {
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSkipPressed() => _completeOnboarding();

  Future<void> _completeOnboarding() async {
    await OnboardingStorageService.setOnboardingCompleted();
    try {
      await NotificationService.instance.permissionService.requestNotificationPermission();
      await NotificationService.instance.permissionService.requestExactAlarmPermission();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(RouteNames.profileSetup);
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: Column(
            children: [
              // ── Top bar with Skip button ──
              SafeArea(
                bottom: false,
                child: _TopBar(
                  isLastPage: _isLastPage,
                  onSkip: _onSkipPressed,
                ),
              ),

              // ── Page content ──
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: onboardingPages.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return OnboardingPageWidget(
                      data: onboardingPages[index],
                    );
                  },
                ),
              ),

              // ── Bottom controls ──
              SafeArea(
                top: false,
                child: _BottomControls(
                  currentPage: _currentPage,
                  pageCount: onboardingPages.length,
                  isLastPage: _isLastPage,
                  activeColor: theme.colorScheme.primary,
                  onNext: _onNextPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Private sub-widgets
// ═══════════════════════════════════════════════════════════════════════════

/// Top-right "Skip" text button. Hidden on the last page since
/// "Get Started" replaces the primary action.
class _TopBar extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onSkip;

  const _TopBar({
    required this.isLastPage,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: isLastPage ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: TextButton(
              onPressed: isLastPage ? null : onSkip,
              child: Text(
                'Skip',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom section containing the page indicator and the
/// Next / Get Started button.
class _BottomControls extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final bool isLastPage;
  final Color activeColor;
  final VoidCallback onNext;

  const _BottomControls({
    required this.currentPage,
    required this.pageCount,
    required this.isLastPage,
    required this.activeColor,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Page indicator ──
          PageIndicator(
            pageCount: pageCount,
            currentPage: currentPage,
            activeColor: activeColor,
            inactiveColor: theme.colorScheme.onSurfaceVariant,
          ),

          const SizedBox(height: 32),

          // ── Action button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0)
                        .animate(animation),
                    child: child,
                  ),
                );
              },
              child: isLastPage
                  ? FilledButton.icon(
                      key: const ValueKey('get_started'),
                      onPressed: onNext,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Get Started'),
                    )
                  : FilledButton(
                      key: const ValueKey('next'),
                      onPressed: onNext,
                      child: const Text('Next'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
