import 'package:flutter/material.dart';

/// Animated progress bar for multi-step wizard flows.
///
/// Displays a horizontal bar that smoothly fills based on
/// [currentStep] / [totalSteps]. Reusable across any stepper UI.
class StepProgressBar extends StatelessWidget {
  /// Current step index (0-based).
  final int currentStep;

  /// Total number of steps.
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (currentStep + 1) / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Step counter label ──
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        // ── Progress track ──
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            width: double.infinity,
            child: Stack(
              children: [
                // Track background
                Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                // Animated fill
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// [FractionallySizedBox] with implicit animation support.
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double? widthFactor;
  final AlignmentGeometry alignment;
  final Widget? child;

  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve,
    this.widthFactor,
    this.alignment = Alignment.center,
    this.child,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor ?? 0,
      (v) => Tween<double>(begin: v as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? 0,
      alignment: widget.alignment,
      child: widget.child,
    );
  }
}
