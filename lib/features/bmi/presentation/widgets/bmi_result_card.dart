import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'bmi_gauge.dart';

class BmiResultCard extends StatelessWidget {
  final double bmi;
  final String category;

  const BmiResultCard({super.key, required this.bmi, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getCategoryColor(category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Calculated BMI',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 10.0, end: bmi),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Text(
                val.toStringAsFixed(1),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 54,
                  color: color,
                  letterSpacing: -1,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey<String>(category),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Circular visual gauge representation
          _buildGaugeBar(bmi, color),
        ],
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'underweight':
        return Colors.blue;
      case 'healthy':
        return AppColors.success;
      case 'overweight':
        return Colors.orange;
      case 'obese':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  Widget _buildGaugeBar(double score, Color categoryColor) {
    return Column(
      children: [
        BmiGauge(
          bmi: score,
          themeColor: categoryColor,
        ),
        const SizedBox(height: 16),
        // Indicator marks
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15.0 (Under)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
            Text('18.5 (Normal)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success)),
            Text('25.0 (Over)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
            Text('30.0 (Obese)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error)),
          ],
        )
      ],
    );
  }
}
