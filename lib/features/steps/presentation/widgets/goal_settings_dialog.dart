import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../step_provider.dart';

Future<void> showGoalSettingsDialog(BuildContext context, StepProvider provider) async {
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
