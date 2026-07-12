import 'package:flutter/material.dart';

/// Step 1 — Welcome
///
/// Displays a warm welcome message with a brief explanation
/// of why profile data is needed. Single "Continue" action.
class StepWelcome extends StatelessWidget {
  const StepWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // ── Icon ──
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 40),

          // ── Title ──
          Text(
            "Let's personalize your\nHealth Companion.",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          // ── Subtitle ──
          Text(
            'This information helps us provide\nbetter recommendations.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
