import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/route_names.dart';
import '../../../shared/widgets/common_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/health_button.dart';
import '../../../shared/animations/animation_helpers.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../settings/presentation/units_provider.dart';
import '../../settings/presentation/widgets/edit_dialogs.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final unitsProv = context.watch<UnitsProvider>();

    final profile = settingsProv.getProfile();

    // BMI badge color
    Color bmiBadgeColor;
    switch (profile.bmiCategory) {
      case 'Healthy':
        bmiBadgeColor = Colors.green;
        break;
      case 'Underweight':
        bmiBadgeColor = Colors.orange;
        break;
      case 'Overweight':
        bmiBadgeColor = Colors.amber;
        break;
      default:
        bmiBadgeColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.settings);
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── HEADER SECTION ──
          Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile.name.isNotEmpty ? profile.name : 'Health User',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${profile.age} Years Old • ${profile.activityLevel}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: bmiBadgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: bmiBadgeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  profile.bmiCategory.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: bmiBadgeColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              HealthButton(
                label: 'Edit Profile',
                icon: Icons.edit_rounded,
                style: HealthButtonStyle.outlined,
                width: 160,
                height: 44,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => EditProfileDialog(
                      profile: profile,
                      onSave: ({
                        required name,
                        required age,
                        required heightCm,
                        required weightKg,
                        required activityLevel,
                        dateOfBirth,
                      }) {
                        settingsProv.updateProfile(
                          name: name,
                          age: age,
                          heightCm: heightCm,
                          weightKg: weightKg,
                          activityLevel: activityLevel,
                          dateOfBirth: dateOfBirth,
                        );
                        HealthSnackBar.showSuccess(context, 'Profile updated successfully! 👤');
                      },
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── DAILY GOALS ──
          FadeInWidget(
            delay: const Duration(milliseconds: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Daily Goals'),
                const SizedBox(height: 12),
                CommonCard(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildGoalRow(context, '💧 Daily Water Goal', '${profile.waterGoalLiters.toStringAsFixed(1)} L (${unitsProv.formatWater(profile.waterGoalLiters * 1000)})'),
                      const SizedBox(height: 14),
                      _buildGoalRow(context, '👣 Daily Step Goal', '${profile.dailyStepGoal} Steps'),
                      const SizedBox(height: 14),
                      _buildGoalRow(context, '😴 Daily Sleep Goal', '${profile.sleepDurationHours.toStringAsFixed(1)} Hours'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGoalRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
          child: const Text('✨', style: TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
