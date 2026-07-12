import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/styled_text_field.dart';
import '../profile_provider.dart';

/// Step 2 — Personal Information
///
/// Collects user's full name and Date of Birth to determine age.
class StepPersonalInfo extends StatefulWidget {
  const StepPersonalInfo({super.key});

  @override
  State<StepPersonalInfo> createState() => _StepPersonalInfoState();
}

class _StepPersonalInfoState extends State<StepPersonalInfo> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProfileProvider>();
    _nameCtrl = TextEditingController(text: provider.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select your birth date';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate(BuildContext context, ProfileProvider provider) async {
    final now = DateTime.now();
    final initialDate = provider.dateOfBirth ?? DateTime(now.year - 25, now.month, now.day);
    final firstDate = DateTime(now.year - 100);
    final lastDate = DateTime(now.year - 1);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      provider.setDateOfBirth(selected);
    }
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
            'Personal Information',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us a bit about yourself.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 32),

          // ── Full Name ──
          StyledTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameCtrl,
            onChanged: provider.setName,
            validator: provider.validateName,
            autofocus: true,
          ),

          const SizedBox(height: 28),

          // ── Date of Birth Selection ──
          Text(
            'Date of Birth',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context, provider),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: provider.dateOfBirth != null
                      ? theme.colorScheme.primary.withValues(alpha: 0.5)
                      : theme.colorScheme.outlineVariant,
                  width: provider.dateOfBirth != null ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: provider.dateOfBirth != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(provider.dateOfBirth),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: provider.dateOfBirth != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: provider.dateOfBirth != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (provider.dateOfBirth != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Calculated Age: ${provider.age} Years Old',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          
          if (provider.dateOfBirth == null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Please select your date of birth to proceed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
