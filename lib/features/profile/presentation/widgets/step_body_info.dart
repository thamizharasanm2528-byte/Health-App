import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/styled_text_field.dart';
import '../profile_provider.dart';

/// Step 3 — Body Information
///
/// Collects height (cm) and weight (kg) with a live BMI preview
/// that updates as the user types.
class StepBodyInfo extends StatefulWidget {
  const StepBodyInfo({super.key});

  @override
  State<StepBodyInfo> createState() => _StepBodyInfoState();
}

class _StepBodyInfoState extends State<StepBodyInfo> {
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProfileProvider>();
    _heightCtrl = TextEditingController(
      text: provider.heightCm > 0 ? provider.heightCm.toStringAsFixed(0) : '',
    );
    _weightCtrl = TextEditingController(
      text: provider.weightKg > 0 ? provider.weightKg.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          Text(
            'Body Information',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll calculate your BMI for you.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 32),

          // ── Height ──
          StyledTextField(
            label: 'Height (cm)',
            hint: 'Enter your height',
            controller: _heightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            onChanged: (v) {
              final h = double.tryParse(v) ?? 0.0;
              provider.setHeightCm(h);
            },
            validator: provider.validateHeight,
          ),

          const SizedBox(height: 24),

          // ── Weight ──
          StyledTextField(
            label: 'Weight (kg)',
            hint: 'Enter your weight',
            controller: _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            onChanged: (v) {
              final w = double.tryParse(v) ?? 0.0;
              provider.setWeightKg(w);
            },
            validator: provider.validateWeight,
          ),

          const SizedBox(height: 36),

          // ── Live BMI Preview ──
          _BmiPreviewCard(bmi: provider.bmi, category: provider.bmiCategory),
        ],
      ),
    );
  }
}

/// Animated card showing the live BMI value and category.
class _BmiPreviewCard extends StatelessWidget {
  final double bmi;
  final String category;

  const _BmiPreviewCard({required this.bmi, required this.category});

  Color _categoryColor(BuildContext context) {
    switch (category) {
      case 'Healthy':
        return const Color(0xFF43A047);
      case 'Underweight':
        return const Color(0xFFFFA726);
      case 'Overweight':
        return const Color(0xFFFF7043);
      case 'Obese':
        return const Color(0xFFE53935);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _categoryColor(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          // ── BMI value ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMI',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bmi > 0 ? bmi.toStringAsFixed(1) : '—',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // ── Category ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Category',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    bmi > 0 ? category : '—',
                    key: ValueKey(category),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
