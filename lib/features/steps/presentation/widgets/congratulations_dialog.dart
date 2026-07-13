import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/widgets/health_button.dart';

void showCongratulationsDialog(BuildContext context) {
  HapticFeedback.mediumImpact();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.bounceOut,
            builder: (context, val, child) {
              return Transform.scale(
                scale: val,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Step Goal Crushed!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.orange,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            "Incredible effort! You have completed today's step target. Keep walking towards a healthier lifestyle!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          HealthButton(
            label: 'Keep Moving!',
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );
}
