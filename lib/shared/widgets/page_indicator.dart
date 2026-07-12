import 'package:flutter/material.dart';

/// Smooth animated page indicator for the onboarding flow.
///
/// Renders a row of dots — the active dot expands into a wider
/// pill shape, while inactive dots remain as small circles.
/// All transitions are smoothly animated.
class PageIndicator extends StatelessWidget {
  /// Total number of pages.
  final int pageCount;

  /// Currently active page index (0-based).
  final int currentPage;

  /// Colour of the active dot.
  final Color activeColor;

  /// Colour of inactive dots.
  final Color inactiveColor;

  const PageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.activeColor,
    this.inactiveColor = const Color(0xFFD0D5DD),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
