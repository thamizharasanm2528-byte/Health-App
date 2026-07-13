import 'package:flutter/material.dart';

class PreviewAndTestRow extends StatelessWidget {
  final String previewText;
  final VoidCallback onTestTap;

  const PreviewAndTestRow({
    super.key,
    required this.previewText,
    required this.onTestTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            previewText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onTestTap,
          icon: const Icon(Icons.bolt_rounded, size: 16),
          label: const Text('Test'),
        ),
      ],
    );
  }
}
