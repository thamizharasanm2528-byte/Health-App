import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'alarm_provider.dart';

class AlarmAlertScreen extends StatefulWidget {
  const AlarmAlertScreen({super.key});

  @override
  State<AlarmAlertScreen> createState() => _AlarmAlertScreenState();
}

class _AlarmAlertScreenState extends State<AlarmAlertScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Timer _timeTimer;
  DateTime _currentTime = DateTime.now();
  
  bool _isPreview = false;
  int _alarmId = 0;
  bool _argsParsed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Vibrating bell icon animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: -0.15,
      upperBound: 0.15,
    )..repeat(reverse: true);

    // Keep screen clock ticking
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsParsed) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is bool) {
        _isPreview = args;
      } else if (args is int) {
        _alarmId = args;
        _isPreview = false;
      }
      _argsParsed = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _animationController.dispose();
    _timeTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alarmProv = context.watch<AlarmProvider>();

    final timeStr = DateFormat('hh:mm').format(_currentTime);
    final periodStr = DateFormat('a').format(_currentTime);
    final dateStr = DateFormat('EEEE, MMMM d').format(_currentTime);

    // Try to find the specific alarm that is ringing to display its label
    String alarmLabel = 'Time to start your healthy routine!';
    if (!_isPreview && _alarmId != 0) {
      final ringingAlarm = alarmProv.alarms.firstWhere((a) => a.id == _alarmId, orElse: () => alarmProv.alarms.first);
      if (ringingAlarm.label.isNotEmpty) {
        alarmLabel = ringingAlarm.label;
      }
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ── Header Status ──
              Column(
                children: [
                  Text(
                    _isPreview ? '🔔 ALARM PREVIEW' : '⏰ WAKE UP!',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPreview ? 'Testing your alarm sound & vibration' : alarmLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // ── Digital Time Display ──
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        timeStr,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 84,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        periodStr,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // ── Animated Vibrating Bell ──
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            blurRadius: 24,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),

              // ── Action Buttons (Snooze / Dismiss) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    // Snooze Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          if (_isPreview) {
                            alarmProv.stopRingtone();
                            nav.pop();
                          } else {
                            await alarmProv.snoozeAlarm(_alarmId);
                            if (alarmProv.wokenByAlarm) {
                              await SystemNavigator.pop();
                            } else {
                              nav.pop();
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.colorScheme.primary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'SNOOZE',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dismiss Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          if (_isPreview) {
                            alarmProv.stopRingtone();
                            nav.pop();
                          } else {
                            await alarmProv.dismissAlarm(_alarmId, context);
                            if (alarmProv.wokenByAlarm) {
                              await SystemNavigator.pop();
                            } else {
                              nav.pop();
                            }
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'DISMISS ALARM',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
