import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/common_card.dart';
import '../../../shared/widgets/health_button.dart';
import '../../../shared/widgets/loading_card.dart';
import 'step_provider.dart';
import 'widgets/step_actions_bar.dart';
import 'widgets/step_chart.dart';
import 'widgets/step_history_list.dart';
import 'widgets/step_progress_card.dart';
import 'widgets/step_streak_card.dart';

/// Step Tracker Screen
///
/// Features animated step ring, step sync actions, streaks,
/// historical activity overview (weekly & monthly toggle), and goal configuration.
class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  Timer? _timer;
  bool _dialogShown = false;
  bool _goalReachedAlertShown = false;

  void _checkGoalMet(StepProvider provider) {
    final today = provider.todayEntry;
    if (today != null && today.isGoalAchieved && !_goalReachedAlertShown) {
      _goalReachedAlertShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCongratulationsDialog(context);
      });
    } else if (today != null && !today.isGoalAchieved) {
      _goalReachedAlertShown = false;
    }
  }

  void _showCongratulationsDialog(BuildContext context) {
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

  @override
  void initState() {
    super.initState();

    // Check status and sync on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StepProvider>();
      provider.checkConnectStatus().then((_) {
        if (provider.hasConnectPermissions) {
          provider.syncSteps();
        }
      });
    });

    // Refresh every 60 seconds while screen is visible
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        context.read<StepProvider>().syncSteps();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showPermanentlyDeniedDialog(BuildContext context, StepProvider provider) {
    if (_dialogShown) return;
    _dialogShown = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Permission Required'),
          content: const Text(
            'Health Companion requires Activity Recognition and Health Connect permissions to automatically read and sync your daily steps. Please enable them in the application settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _dialogShown = false;
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(ctx);
                _dialogShown = false;
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openPlayStore() async {
    final url = Uri.parse('https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> actions,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: CommonCard(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ...actions.map((act) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: act,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String _getMotivationalMessage(int steps) {
    if (steps < 3000) {
      return "Every step is a step closer to your fitness goals! Let's get moving. 🚶‍♂️";
    } else if (steps < 7000) {
      return "Great progress! You are on your way to meeting today's target. Keep pushing! 🚀";
    } else if (steps < 10000) {
      return "Amazing! Almost there. Just a little more walk to hit the goal! ⚡";
    } else {
      return "Outstanding! You've crushed today's step goal. Outstanding achievement! 🏆";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<StepProvider>();
    final today = provider.todayEntry;

    // Check goal progression
    _checkGoalMet(provider);

    // Check for permanent permission denial
    if (provider.isPermissionsPermanentlyDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPermanentlyDeniedDialog(context, provider);
      });
    }

    // Trigger showing snackbar errors if sync fails
    if (provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      });
    }

    final showEmptyState = today == null || today.steps == 0;

    Widget body;
    if (provider.isSyncing && showEmptyState) {
      body = const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            LoadingCard(height: 180),
            SizedBox(height: 20),
            LoadingCard(height: 80),
            SizedBox(height: 20),
            LoadingCard(height: 120),
          ],
        ),
      );
    } else if (showEmptyState && Platform.isAndroid && provider.connectStatus == HealthConnectSdkStatus.sdkUnavailable) {
      body = _buildEmptyState(
        context: context,
        icon: Icons.download_rounded,
        title: 'Health Connect Not Installed',
        subtitle: 'Google Health Connect is required to sync steps automatically on Android. Install it from the Play Store to get started.',
        actions: [
          HealthButton(
            onPressed: _openPlayStore,
            icon: Icons.install_mobile_rounded,
            label: 'Install Health Connect',
          ),
        ],
      );
    } else if (showEmptyState && Platform.isAndroid && provider.connectStatus == HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
      body = _buildEmptyState(
        context: context,
        icon: Icons.update_rounded,
        title: 'Update Required',
        subtitle: 'Health Connect needs to be updated to the latest version to sync your activity data automatically.',
        actions: [
          HealthButton(
            onPressed: _openPlayStore,
            icon: Icons.install_mobile_rounded,
            label: 'Update Health Connect',
          ),
        ],
      );
    } else if (showEmptyState && !provider.isConnectSupported) {
      body = _buildEmptyState(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'Device Not Supported',
        subtitle: 'Health Connect integration is not supported on this platform. An Android device with Google Play Services and Health Connect is required.',
        actions: [
          HealthButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.arrow_back_rounded,
            label: 'Go Back',
          ),
        ],
      );
    } else if (showEmptyState && !provider.hasConnectPermissions) {
      body = _buildEmptyState(
        context: context,
        icon: Icons.settings_suggest_rounded,
        title: 'Permissions Required',
        subtitle: 'Enable Health permissions to automatically read and sync today\'s step count.',
        actions: [
          HealthButton(
            onPressed: () => provider.syncSteps(),
            icon: Icons.sync_rounded,
            label: 'Sync & Grant Permissions',
          ),
          if (provider.isPermissionsPermanentlyDenied) ...[
            const SizedBox(height: 8),
            HealthButton(
              onPressed: openAppSettings,
              icon: Icons.settings_rounded,
              label: 'Open App Settings',
              style: HealthButtonStyle.outlined,
            ),
          ]
        ],
      );
    } else {
      // Normal display body
      body = RefreshIndicator(
        onRefresh: () => provider.syncSteps(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning banner if permissions are missing
              if (!provider.hasConnectPermissions && today != null && today.steps > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Card(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.15),
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      title: const Text('Not Synced with Health Connect'),
                      subtitle: const Text('Grant health permissions to enable automatic step sync.'),
                      trailing: TextButton(
                        onPressed: () => provider.syncSteps(),
                        child: const Text('Enable'),
                      ),
                    ),
                  ),
                ),

              // ── Progress Card ──
              if (today != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StepProgressCard(
                    steps: today.steps,
                    goal: today.goal,
                    progress: today.progress,
                    progressPercent: today.progressPercent,
                    isGoalAchieved: today.isGoalAchieved,
                    isSynced: today.isSynced,
                  ),
                ),

              const SizedBox(height: 20),

              // ── Motivational Card ──
              if (today != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CommonCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _getMotivationalMessage(today.steps),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ── Step Actions ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StepActionsBar(
                  isSyncing: provider.isSyncing,
                  onSync: () => provider.syncSteps(),
                  onChangeGoal: () => _showGoalSettingsDialog(context, provider),
                ),
              ),

              const SizedBox(height: 24),

              // ── Streaks ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StepStreakCard(
                  currentStreak: provider.currentStreak,
                  bestStreak: provider.bestStreak,
                ),
              ),

              const SizedBox(height: 24),

              // ── Weekly/Monthly Chart ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StepChart(
                  last30Days: provider.getRangeEntries(30),
                  currentGoal: provider.currentGoal,
                  calculator: provider.calculateStats,
                ),
              ),

              const SizedBox(height: 24),

              // ── History ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StepHistoryList(
                  entries: provider.historyEntries,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_walk_rounded,
              color: AppColors.steps,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              'Step Tracker',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,

      ),
      body: body,
    );
  }

  // ── Action Dialogs ──────────────────────────────────────────────────

  Future<void> _showGoalSettingsDialog(BuildContext context, StepProvider provider) async {
    final controller = TextEditingController(text: provider.currentGoal.toString());
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Set Daily Goal'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Daily target',
                hintText: 'e.g. 10000',
                suffixText: 'steps',
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Please enter goal';
                final parsed = int.tryParse(val);
                if (parsed == null || parsed < 1000) return 'Minimum goal is 1000';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final target = int.parse(controller.text);
                  provider.updateGoal(target);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Daily step goal updated successfully!'),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
