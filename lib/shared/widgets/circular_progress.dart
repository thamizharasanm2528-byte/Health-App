import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated circular progress indicator with a gradient stroke.
///
/// Reusable across health score, water intake, and other
/// progress visualisations throughout the app.
class CircularProgress extends StatefulWidget {
  /// Progress value from 0.0 to 1.0.
  final double progress;

  /// Diameter of the circle.
  final double size;

  /// Width of the progress stroke.
  final double strokeWidth;

  /// Gradient colours for the progress arc.
  final List<Color> gradientColors;

  /// Background track colour.
  final Color? trackColor;

  /// Widget displayed in the centre of the circle.
  final Widget? child;

  /// Animation duration.
  final Duration duration;

  const CircularProgress({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.gradientColors = const [Color(0xFF2E7D52), Color(0xFF66BB6A)],
    this.trackColor,
    this.child,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<CircularProgress> createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _oldProgress = _animation.value;
      _animation = Tween<double>(begin: _oldProgress, end: widget.progress)
          .animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackColor =
        widget.trackColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _CircularProgressPainter(
                progress: _animation.value.clamp(0.0, 1.0),
                strokeWidth: widget.strokeWidth,
                gradientColors: widget.gradientColors,
                trackColor: trackColor,
              ),
              child: Center(child: widget.child),
            ),
          ),
        );
      },
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color trackColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    // ── Track ──
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // ── Progress arc with gradient ──
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: gradientColors,
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
