import 'package:flutter/material.dart';
import '../../core/constants/app_values.dart';

/// Reusable premium dialog window supporting standard styling and action padding.
class HealthDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const HealthDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SingleChildScrollView(
        child: content,
      ),
      actions: actions,
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, AppSpacing.xl, AppSpacing.xl),
    );
  }
}
