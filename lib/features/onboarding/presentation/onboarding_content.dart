import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'onboarding_page_data.dart';

/// The five onboarding pages content.
///
/// Each entry maps to a screen in the [PageView]. Icons serve as
/// illustration placeholders until real SVG/image assets are added.
const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    icon: Icons.monitor_heart_rounded,
    color: AppColors.primary,
    title: 'Track Your Health',
    description:
        'Monitor your daily health metrics in one place — steps, water, '
        'sleep, BMI, and nutrition all at your fingertips.',
  ),
  OnboardingPageData(
    icon: Icons.water_drop_rounded,
    color: AppColors.water,
    title: 'Stay Hydrated',
    description:
        'Set daily water intake goals, log every glass, and receive '
        'smart reminders to keep you hydrated throughout the day.',
  ),
  OnboardingPageData(
    icon: Icons.directions_run_rounded,
    color: AppColors.steps,
    title: 'Count Every Step',
    description:
        'Connect to Google Health Connect or Apple Health and track '
        'your steps automatically with beautiful progress charts.',
  ),
  OnboardingPageData(
    icon: Icons.bedtime_rounded,
    color: AppColors.sleep,
    title: 'Sleep Better',
    description:
        'Log your sleep schedule, discover patterns, and build '
        'healthier bedtime habits for restorative rest.',
  ),
];
