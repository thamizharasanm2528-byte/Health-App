import 'package:flutter/material.dart';

class LoadingCard extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;

  const LoadingCard({
    super.key,
    this.height = 120.0,
    this.width = double.infinity,
    this.borderRadius = 24.0,
  });

  @override
  State<LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<LoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHigh
                  : theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}
