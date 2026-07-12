import 'package:flutter/material.dart';

/// Standardized custom header App Bar supporting flexible leading/trailing slots and bold titles.
class HealthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showDivider;

  const HealthAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      leading: leading,
      actions: actions,
      elevation: 0,
      centerTitle: true,
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                height: 1,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
