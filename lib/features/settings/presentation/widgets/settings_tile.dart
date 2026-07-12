import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    this.icon,
    this.emoji,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget leadingWidget;
    if (emoji != null) {
      leadingWidget = CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        radius: 20,
        child: Text(
          emoji!,
          style: const TextStyle(fontSize: 18),
        ),
      );
    } else if (icon != null) {
      leadingWidget = CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        radius: 20,
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      );
    } else {
      leadingWidget = const SizedBox(width: 8);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: leadingWidget,
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded) : null),
      onTap: onTap,
    );
  }
}
