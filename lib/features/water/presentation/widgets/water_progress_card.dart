import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/circular_progress.dart';

class WaterProgressCard extends StatelessWidget {
  final double intakeLiters;
  final double goalLiters;
  final double remainingLiters;
  final double progress;
  final int progressPercent;
  final bool goalMet;

  const WaterProgressCard({
    super.key,
    required this.intakeLiters,
    required this.goalLiters,
    required this.remainingLiters,
    required this.progress,
    required this.progressPercent,
    required this.goalMet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.water, AppColors.water.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.water.withValues(alpha: isDark ? 0.15 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Circular progress wrapping Wave ──
          CircularProgress(
            progress: progress.clamp(0.0, 1.0),
            size: 150,
            strokeWidth: 10,
            gradientColors: const [Colors.white, Color(0x88FFFFFF)],
            trackColor: Colors.white.withValues(alpha: 0.15),
            child: WaveProgress(
              progress: progress.clamp(0.0, 1.0),
              size: 130,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${intakeLiters.toStringAsFixed(1)}L',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'of ${goalLiters.toStringAsFixed(1)}L',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Stats row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn(label: 'Progress', value: '$progressPercent%'),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              _StatColumn(
                label: 'Remaining',
                value: '${remainingLiters.toStringAsFixed(1)}L',
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              _StatColumn(
                label: 'Status',
                value: goalMet ? 'Goal Met! 🎉' : 'In Progress',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// An infinite wave animation inside circular boundary representing water fill levels
class WaveProgress extends StatefulWidget {
  final double progress;
  final double size;
  final Widget child;

  const WaveProgress({
    super.key,
    required this.progress,
    required this.size,
    required this.child,
  });

  @override
  State<WaveProgress> createState() => _WaveProgressState();
}

class _WaveProgressState extends State<WaveProgress>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _levelController;
  late Animation<double> _levelAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _levelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _levelAnimation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _levelController, curve: Curves.easeOutCubic),
    );
    _levelController.forward();
  }

  @override
  void didUpdateWidget(covariant WaveProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _levelAnimation =
          Tween<double>(
            begin: _levelAnimation.value,
            end: widget.progress,
          ).animate(
            CurvedAnimation(
              parent: _levelController,
              curve: Curves.easeOutCubic,
            ),
          );
      _levelController.reset();
      _levelController.forward();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_waveController, _levelAnimation]),
        builder: (context, child) {
          return RepaintBoundary(
            child: CustomPaint(
              painter: _WavePainter(
                progress: _levelAnimation.value,
                waveOffset: _waveController.value * 2 * math.pi,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final double waveOffset;

  _WavePainter({required this.progress, required this.waveOffset});

  @override
  void paint(Canvas canvas, Size size) {
    // Amplitude smooth-scaling to 0 at empty (0.0) or full (1.0) bounds to prevent overflow clipping gaps
    final amplitude = 6.0 * math.sin(progress * math.pi);
    final yCenter = size.height * (1.0 - progress);

    // 1. Background Wave (different phase/amplitude, lower opacity)
    final paintBg = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final pathBg = Path();
    pathBg.moveTo(0, size.height);
    pathBg.lineTo(0, yCenter);

    for (double x = 0; x <= size.width; x++) {
      final y = yCenter + math.sin(x / size.width * 2 * math.pi + waveOffset + math.pi) * (amplitude * 0.7);
      pathBg.lineTo(x, y);
    }

    pathBg.lineTo(size.width, size.height);
    pathBg.close();
    canvas.drawPath(pathBg, paintBg);

    // 2. Foreground Wave (primary phase/amplitude, higher opacity)
    final paintFg = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final pathFg = Path();
    pathFg.moveTo(0, size.height);
    pathFg.lineTo(0, yCenter);

    for (double x = 0; x <= size.width; x++) {
      final y = yCenter + math.sin(x / size.width * 2 * math.pi + waveOffset) * amplitude;
      pathFg.lineTo(x, y);
    }

    pathFg.lineTo(size.width, size.height);
    pathFg.close();
    canvas.drawPath(pathFg, paintFg);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveOffset != waveOffset;
  }
}
