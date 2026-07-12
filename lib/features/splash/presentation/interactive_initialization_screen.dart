import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A premium, highly interactive and aesthetic initialization screen.
/// Shown if startup/init operations take extra time.
/// Users can tap and drag to generate beautiful glowing ripples and floating particles,
/// while observing a pulsing heartbeat logo and dynamic status messages.
class InteractiveInitializationScreen extends StatefulWidget {
  const InteractiveInitializationScreen({super.key});

  @override
  State<InteractiveInitializationScreen> createState() =>
      _InteractiveInitializationScreenState();
}

class _InteractiveInitializationScreenState
    extends State<InteractiveInitializationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heartbeatController;
  late final Animation<double> _heartScale;
  late final Animation<double> _glowOpacity;

  late final AnimationController _waveController;

  // Status messages that cycle during load
  final List<String> _statusMessages = [
    'Opening database chambers...',
    'Calibrating wellness engine...',
    'Syncing daily stats...',
    'Synthesizing health scores...',
    'Preparing your companion...',
  ];
  int _currentMessageIndex = 0;
  late final ValueNotifier<String> _statusMessageNotifier;

  // Interactive Touch Elements
  final List<_RippleEffect> _ripples = [];
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _statusMessageNotifier = ValueNotifier(_statusMessages[0]);

    // Heartbeat animations
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.05).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.2).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 10),
    ]).animate(_heartbeatController);

    _glowOpacity = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(
        parent: _heartbeatController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Wave loader animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Periodically change status message
    _cycleStatusMessages();
  }

  void _cycleStatusMessages() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) break;
      _currentMessageIndex = (_currentMessageIndex + 1) % _statusMessages.length;
      _statusMessageNotifier.value = _statusMessages[_currentMessageIndex];
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _addInteraction(details.localPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    // Only spawn periodically to prevent overwhelming performance
    if (_random.nextDouble() < 0.25) {
      _addInteraction(details.localPosition);
    }
  }

  void _addInteraction(Offset position) {
    if (!mounted) return;
    setState(() {
      // Add ripple
      _ripples.add(
        _RippleEffect(
          position: position,
          color: HSLColor.fromColor(AppColors.primary)
              .withHue((120 + _random.nextInt(60)).toDouble())
              .toColor(),
          controller: AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1200),
          )..forward(),
        ),
      );

      // Spawn particles
      for (int i = 0; i < 4; i++) {
        _particles.add(
          _Particle(
            position: position,
            velocity: Offset(
              (_random.nextDouble() - 0.5) * 3,
              -1.5 - _random.nextDouble() * 2,
            ),
            size: 4 + _random.nextDouble() * 8,
            color: Color.lerp(
              AppColors.primary,
              AppColors.secondary,
              _random.nextDouble(),
            )!.withValues(alpha: 0.8),
            maxLife: 60 + _random.nextInt(60),
          ),
        );
      }
    });

    // Cleanup dead ripples
    _ripples.removeWhere((r) {
      if (r.controller.isCompleted) {
        r.controller.dispose();
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _waveController.dispose();
    _statusMessageNotifier.dispose();
    for (final r in _ripples) {
      r.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic updates for moving particles
    if (_particles.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          for (final p in _particles) {
            p.update();
          }
          _particles.removeWhere((p) => p.life <= 0);
        });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F9F68),
      body: GestureDetector(
        onTapDown: _handleTapDown,
        onPanUpdate: _handlePanUpdate,
        child: Stack(
          children: [
            // ── Background Gradient (matching 2nd image) ──
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF23B277),
                      Color(0xFF0F9F68),
                    ],
                  ),
                ),
              ),
            ),

            // Subtle bright radial highlight
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.1),
                    radius: 1.0,
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Ripples and Particles Painter ──
            Positioned.fill(
              child: CustomPaint(
                painter: _InteractionPainter(
                  ripples: _ripples,
                  particles: _particles,
                ),
              ),
            ),

            // ── Central Interactive Pulsing Engine ──
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with heartbeat scale & breathing glow
                  AnimatedBuilder(
                    animation: _heartbeatController,
                    builder: (context, child) {
                      return Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: _glowOpacity.value),
                              blurRadius: 35,
                              spreadRadius: 8 * _glowOpacity.value,
                            ),
                          ],
                        ),
                        child: Transform.scale(
                          scale: _heartScale.value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 68,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),

                  // Health Companion Premium Text
                  const Text(
                    'HEALTH COMPANION',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // User Helper Message
                  const Text(
                    'Tap or drag anywhere to interact',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white38,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Progress Status Waves ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 140,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Dynamic Bezier Waves
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(double.infinity, 120),
                          painter: _WavePainter(
                            waveValue: _waveController.value,
                          ),
                        );
                      },
                    ),

                    // Status Messages Card
                    Positioned(
                      bottom: 40,
                      child: ValueListenableBuilder<String>(
                        valueListenable: _statusMessageNotifier,
                        builder: (context, message, child) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.4),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              key: ValueKey<String>(message),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white10,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.primary),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    message,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper model for generating touch ripples.
class _RippleEffect {
  final Offset position;
  final Color color;
  final AnimationController controller;

  _RippleEffect({
    required this.position,
    required this.color,
    required this.controller,
  });
}

/// Helper model for spawning floating particles.
class _Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  int life;
  int maxLife;

  _Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.maxLife,
  }) : life = maxLife;

  void update() {
    position += velocity;
    velocity = Offset(velocity.dx * 0.98, velocity.dy * 0.98); // deceleration
    life--;
  }
}

/// Custom painter for interactive user taps (ripples & particles).
class _InteractionPainter extends CustomPainter {
  final List<_RippleEffect> ripples;
  final List<_Particle> particles;

  _InteractionPainter({required this.ripples, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw ripples
    for (final r in ripples) {
      final t = r.controller.value;
      final opacity = 1.0 - t;
      final radius = t * 90;

      final paint = Paint()
        ..color = r.color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1.0 - t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(r.position, radius, paint);
    }

    // 2. Draw particles
    for (final p in particles) {
      final lifeFraction = p.life / p.maxLife;
      final paint = Paint()
        ..color = p.color.withValues(alpha: lifeFraction)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(p.position, p.size * lifeFraction, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _InteractionPainter oldDelegate) => true;
}

/// Custom waves painter at the bottom screen area.
class _WavePainter extends CustomPainter {
  final double waveValue;

  _WavePainter({required this.waveValue});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // First wave (secondary wave)
    final path1 = Path();
    final paint1 = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    path1.moveTo(0, height);
    for (double i = 0; i <= width; i++) {
      final angle = (i / width * 2 * math.pi) + (waveValue * 2 * math.pi);
      final y = math.sin(angle) * 12 + 40;
      path1.lineTo(i, height - y);
    }
    path1.lineTo(width, height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Second wave (primary brand wave)
    final path2 = Path();
    final paint2 = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    path2.moveTo(0, height);
    for (double i = 0; i <= width; i++) {
      final angle = (i / width * 2 * math.pi) - (waveValue * 2 * math.pi) + math.pi / 2;
      final y = math.cos(angle) * 15 + 30;
      path2.lineTo(i, height - y);
    }
    path2.lineTo(width, height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.waveValue != waveValue;
}
