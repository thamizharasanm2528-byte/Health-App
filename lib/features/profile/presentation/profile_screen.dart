import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/route_names.dart';
import '../../../shared/widgets/step_progress_bar.dart';
import 'profile_provider.dart';
import 'widgets/step_activity_level.dart';
import 'widgets/step_body_info.dart';
import 'widgets/step_daily_goals.dart';
import 'widgets/step_personal_info.dart';
import 'widgets/step_sleep_schedule.dart';
import 'widgets/step_summary.dart';
import 'widgets/step_welcome.dart';

/// Profile Setup Screen
///
/// Multi-step wizard that collects the user's health profile
/// using an animated [PageView] with progress indicator,
/// Back / Next / Finish buttons, and step validation.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Step pages ──────────────────────────────────────────────────────

  static const _steps = <Widget>[
    StepWelcome(),          // 0
    StepPersonalInfo(),     // 1
    StepBodyInfo(),         // 2
    StepActivityLevel(),    // 3
    StepDailyGoals(),       // 4
    StepSleepSchedule(),    // 5
    StepSummary(),          // 6
  ];

  // ── Navigation helpers ──────────────────────────────────────────────

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onNext(ProfileProvider provider) {
    if (!provider.canProceed) return;

    if (provider.isLastStep) {
      _finishSetup(provider);
    } else {
      provider.nextStep();
      _animateToPage(provider.currentStep);
    }
  }

  void _onBack(ProfileProvider provider) {
    provider.previousStep();
    _animateToPage(provider.currentStep);
  }

  Future<void> _finishSetup(ProfileProvider provider) async {
    final success = await provider.saveProfile();
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteNames.dashboard,
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save profile. Please try again.')),
      );
    }
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      body: Column(
        children: [
          // ── Progress bar ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: StepProgressBar(
                currentStep: provider.currentStep,
                totalSteps: ProfileProvider.totalSteps,
              ),
            ),
          ),

          // ── Page content ──
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _steps[index],
                );
              },
            ),
          ),

          // ── Bottom buttons ──
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  // ── Back ──
                  if (!provider.isFirstStep)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _onBack(provider),
                        child: const Text('Back'),
                      ),
                    )
                  else
                    const Spacer(),

                  const SizedBox(width: 16),

                  // ── Next / Finish ──
                  Expanded(
                    flex: 2,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: provider.isLastStep
                          ? FilledButton.icon(
                              key: const ValueKey('finish'),
                              onPressed: provider.canProceed
                                  ? () => _onNext(provider)
                                  : null,
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Finish Setup'),
                            )
                          : FilledButton(
                              key: ValueKey('next_${provider.currentStep}'),
                              onPressed: provider.canProceed
                                  ? () => _onNext(provider)
                                  : null,
                              child: Text(
                                provider.isFirstStep ? 'Continue' : 'Next',
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
