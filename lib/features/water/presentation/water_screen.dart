import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/health_button.dart';
import '../../../shared/animations/animation_helpers.dart';
import 'water_provider.dart';
import 'widgets/quick_add_buttons.dart';
import 'widgets/water_history_list.dart';
import 'widgets/water_progress_card.dart';
import 'widgets/water_reminder_card.dart';
import 'widgets/water_streak_card.dart';
import 'widgets/weekly_chart.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  bool _showRipple = false;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _triggerRipple() {
    setState(() {
      _showRipple = true;
    });
    _rippleController.forward(from: 0.0).then((_) {
      setState(() {
        _showRipple = false;
      });
    });
  }

  void _checkGoalMet(WaterProvider provider) {
    if (provider.goalMet && !provider.hasShownGoalAlertToday) {
      provider.markGoalAlertShownToday();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCongratulationsDialog(context);
      });
    }
  }

  void _showCongratulationsDialog(BuildContext context) {
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
                  child: const Text('🎉', style: TextStyle(fontSize: 64)),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Goal Achieved!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.water,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Fantastic job! You have reached your hydration goal for today. Keep up the healthy habits!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            HealthButton(
              label: 'Awesome!',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WaterProvider>();
    
    // Check goal progression
    _checkGoalMet(provider);

    if (provider.lastError != null) {
      final error = provider.lastError!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        provider.clearLastError();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App Bar ──
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const PulseWidget(
                              child: Icon(
                                Icons.water_drop_rounded,
                                color: AppColors.water,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Water Tracker',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppColors.water),
                          tooltip: 'Set Goal',
                          onPressed: () => _showSetGoalDialog(context, provider),
                        ),
                      ],
                    ),
                  ),
                ),

                  const SizedBox(height: 16),

                  // ── Progress Card ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WaterProgressCard(
                      intakeLiters: provider.todayIntakeLiters,
                      goalLiters: provider.goalLiters,
                      remainingLiters: provider.remainingLiters,
                      progress: provider.progress,
                      progressPercent: provider.progressPercent,
                      goalMet: provider.goalMet,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Add Water Hero Button ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: HealthButton(
                      label: 'Log 250ml Water',
                      icon: Icons.water_drop_rounded,
                      onPressed: () {
                        provider.addWater(250);
                        _triggerRipple();
                        HealthSnackBar.showSuccess(context, 'Logged 250ml water successfully! 💧');
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Quick Add Presets ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: QuickAddButtons(
                      onAdd: (ml) {
                        provider.addWater(ml);
                        _triggerRipple();
                        HealthSnackBar.showSuccess(context, 'Logged ${ml}ml water successfully! 💧');
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Today's Hydration Timeline ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WaterHistoryList(
                      entries: provider.todayEntries,
                      onEdit: (entry) => provider.updateEntry(entry.id, entry.amountMl),
                      onDelete: (id) => provider.deleteEntry(id),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Weekly Chart Analytics ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FadeInWidget(
                      delay: const Duration(milliseconds: 200),
                      child: WeeklyChart(
                        data: provider.weeklyData,
                        goalLiters: provider.goalLiters,
                        weeklyAverageMl: provider.weeklyAverageMl,
                        weeklyHighestMl: provider.weeklyHighestMl,
                        weeklyLowestMl: provider.weeklyLowestMl,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Streak Tracking Card ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WaterStreakCard(
                      currentStreak: provider.currentStreak,
                      bestStreak: provider.bestStreak,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Notification Reminder Panel ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WaterReminderCard(
                      enabled: provider.remindersEnabled,
                      intervalMinutes: provider.reminderIntervalMinutes,
                      startHour: provider.reminderStartHour,
                      endHour: provider.reminderEndHour,
                      onManagePressed: () {
                        Navigator.pushNamed(context, RouteNames.reminderSettings);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

          // ── Water addition ripple animation overlay ──
          if (_showRipple)
            IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (context, child) {
                    return Container(
                      width: _rippleAnimation.value * 300,
                      height: _rippleAnimation.value * 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.water.withValues(alpha: 0.15 * (1.0 - _rippleAnimation.value)),
                        border: Border.all(
                          color: AppColors.water.withValues(alpha: 0.4 * (1.0 - _rippleAnimation.value)),
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSetGoalDialog(BuildContext context, WaterProvider provider) {
    final controller = TextEditingController(text: provider.goalLiters.toStringAsFixed(1));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Daily Water Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your daily hydration goal in liters:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Daily Goal (Liters)',
                suffixText: 'L',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final liters = double.tryParse(controller.text);
              if (liters != null && liters > 0) {
                await provider.updateWaterGoal(liters);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
