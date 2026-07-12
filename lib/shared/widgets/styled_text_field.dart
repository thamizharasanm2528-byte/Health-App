import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Themed text field with built-in label, hint, validation,
/// and optional suffix/prefix.
///
/// Follows the app's Material 3 [InputDecorationTheme] and adds
/// consistent spacing and label styling.
class StyledTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final Widget? prefix;
  final bool autofocus;

  const StyledTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.suffixIcon,
    this.prefix,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),

        // ── Input ──
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefix: prefix,
          ),
        ),
      ],
    );
  }
}
