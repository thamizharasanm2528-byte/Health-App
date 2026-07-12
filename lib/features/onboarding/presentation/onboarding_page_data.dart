import 'package:flutter/material.dart';

/// Data model for a single onboarding page.
///
/// Holds the icon, colour, title, and description for each step
/// in the onboarding flow. Used by [OnboardingPageWidget] to
/// render content.
class OnboardingPageData {
  /// Material icon displayed as the illustration placeholder.
  final IconData icon;

  /// Accent colour for the icon container.
  final Color color;

  /// Bold headline text.
  final String title;

  /// Supporting description text.
  final String description;

  const OnboardingPageData({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
