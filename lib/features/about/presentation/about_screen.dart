import 'package:flutter/material.dart';
import '../../../core/constants/app_values.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../shared/widgets/health_card.dart';

/// Premium About Screen showcasing app identity, version, developer, and legal info.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        children: [
          // ── Logo & Identity ──
          Center(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.l),
                // App Logo programmatic
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        AppColors.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Health Companion',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Build Healthy Habits Every Day',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Text(
                    'Version 1.0.0 (Build 1)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),

          // ── Features Highlight ──
          HealthCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Features',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                _buildFeatureRow(context, Icons.water_drop_rounded, 'Water Tracking', AppColors.water),
                _buildFeatureRow(context, Icons.directions_walk_rounded, 'Step Counter', AppColors.steps),
                _buildFeatureRow(context, Icons.bedtime_rounded, 'Sleep Monitoring', AppColors.sleep),
                _buildFeatureRow(context, Icons.monitor_weight_rounded, 'BMI Calculator', AppColors.bmi),
                _buildFeatureRow(context, Icons.alarm_rounded, 'Wake-up Alarm', theme.colorScheme.primary),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.l),

          // ── Developer Info ──
          HealthCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Developer',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                _buildInfoRow(context, Icons.code_rounded, 'Built with Flutter'),
                _buildInfoRow(context, Icons.architecture_rounded, 'Clean Architecture'),
                _buildInfoRow(context, Icons.storage_rounded, 'Powered by Hive'),
                _buildInfoRow(context, Icons.palette_rounded, 'Material 3 Design'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.l),

          // ── Legal ──
          HealthCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Legal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                _buildLegalTile(
                  context,
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  'Your data stays on your device',
                ),
                const Divider(height: AppSpacing.xxl),
                _buildLegalTile(
                  context,
                  Icons.description_outlined,
                  'Terms & Conditions',
                  'Usage terms and guidelines',
                ),
                const Divider(height: AppSpacing.xxl),
                _buildLegalTile(
                  context,
                  Icons.source_outlined,
                  'Open Source Licenses',
                  'Third-party packages used',
                  onTap: () => Navigator.pushNamed(context, RouteNames.licenses),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // ── Footer ──
          Center(
            child: Text(
              'Made with ❤️ for a healthier you',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String label, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.m),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.m),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}
