import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BmiGauge extends StatelessWidget {
  final double bmi;
  final Color themeColor;

  const BmiGauge({
    super.key,
    required this.bmi,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    if (disableAnimations) {
      return RepaintBoundary(
        child: CustomPaint(
          size: const Size(220, 120),
          painter: BmiGaugePainter(bmi: bmi, themeColor: themeColor),
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 15.0, end: bmi),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutBack,
      builder: (context, animBmi, child) {
        return RepaintBoundary(
          child: CustomPaint(
            size: const Size(220, 120),
            painter: BmiGaugePainter(bmi: animBmi, themeColor: themeColor),
          ),
        );
      },
    );
  }
}

class BmiGaugePainter extends CustomPainter {
  final double bmi;
  final Color themeColor;

  BmiGaugePainter({required this.bmi, required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = size.width / 2 - 10;
    
    // Draw semi-circle track
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final startAngle = math.pi;
    final totalSweep = math.pi;

    // We map BMI from 15 to 35 (range = 20)
    // Draw segments: Underweight (15 to 18.5 -> 3.5 units)
    paint.color = Colors.blue.withValues(alpha: 0.8);
    canvas.drawArc(rect, startAngle, totalSweep * (3.5 / 20.0), false, paint);

    // Healthy (18.5 to 25.0 -> 6.5 units)
    paint.color = AppColors.success.withValues(alpha: 0.8);
    canvas.drawArc(rect, startAngle + totalSweep * (3.5 / 20.0), totalSweep * (6.5 / 20.0), false, paint);

    // Overweight (25.0 to 30.0 -> 5.0 units)
    paint.color = Colors.orange.withValues(alpha: 0.8);
    canvas.drawArc(rect, startAngle + totalSweep * (10.0 / 20.0), totalSweep * (5.0 / 20.0), false, paint);

    // Obese (30.0 to 35.0 -> 5.0 units)
    paint.color = AppColors.error.withValues(alpha: 0.8);
    canvas.drawArc(rect, startAngle + totalSweep * (15.0 / 20.0), totalSweep * (5.0 / 20.0), false, paint);

    // Calculate needle angle
    final fraction = ((bmi - 15.0) / 20.0).clamp(0.0, 1.0);
    final needleAngle = math.pi + fraction * math.pi;

    // Draw needle
    final needlePaint = Paint()
      ..color = themeColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final needleLength = radius - 15;
    final tip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );
    canvas.drawLine(center, tip, needlePaint);

    // Draw pivot center
    final pivotPaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, pivotPaint);

    final pivotCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, pivotCenterPaint);
  }

  @override
  bool shouldRepaint(covariant BmiGaugePainter oldDelegate) {
    return oldDelegate.bmi != bmi || oldDelegate.themeColor != themeColor;
  }
}
