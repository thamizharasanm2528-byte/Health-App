import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/animations/animation_helpers.dart';

class HealthyWeightCard extends StatelessWidget {
  final String range;
  final double currentWeight;
  final double targetWeight;
  final double difference;
  final double progress;
  final String goalMessage;
  final ValueChanged<double> onUpdateTarget;

  const HealthyWeightCard({
    super.key,
    required this.range,
    required this.currentWeight,
    required this.targetWeight,
    required this.difference,
    required this.progress,
    required this.goalMessage,
    required this.onUpdateTarget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Healthy Weight Target',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                color: AppColors.bmi,
                onPressed: () => _showTargetDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Recommended Range: ', style: TextStyle(fontSize: 13)),
              Text(
                range,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              _buildMetricCol(context, 'Current', '${currentWeight.toStringAsFixed(1)} kg'),
              _buildDivider(),
              _buildMetricCol(context, 'Target', '${targetWeight.toStringAsFixed(1)} kg'),
              _buildDivider(),
              _buildMetricCol(context, 'Diff', '${difference.toStringAsFixed(1)} kg'),
            ],
          ),
          const SizedBox(height: 16),
          // Goal Progress Slider Bar
          Text(
            'Target Progress',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutCubic,
            builder: (context, animVal, child) {
              return Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: animVal,
                        minHeight: 8,
                        backgroundColor: AppColors.bmi.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation(AppColors.bmi),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(animVal * 100).round()}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.bmi,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            goalMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(BuildContext context, String title, String val) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Future<void> _showTargetDialog(BuildContext context) async {
    final controller = TextEditingController(text: targetWeight.toStringAsFixed(1));
    final formKey = GlobalKey<FormState>();
    final shakeKey = GlobalKey<ShakeWidgetState>();

    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Edit Target Weight'),
          content: Form(
            key: formKey,
            child: ShakeWidget(
              key: shakeKey,
              child: TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Target Weight (kg)',
                  suffixText: 'kg',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter target';
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed < 10 || parsed > 300) {
                    return 'Enter 10 to 300 kg';
                  }
                  return null;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final target = double.parse(controller.text);
                  onUpdateTarget(target);
                  Navigator.pop(ctx);
                } else {
                  shakeKey.currentState?.shake();
                  HapticFeedback.heavyImpact();
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
