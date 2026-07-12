import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Interaction buttons for steps: sync now and change goal.
class StepActionsBar extends StatelessWidget {
  final bool isSyncing;
  final VoidCallback onSync;
  final VoidCallback onChangeGoal;

  const StepActionsBar({
    super.key,
    required this.isSyncing,
    required this.onSync,
    required this.onChangeGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Quick Actions',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            // ── Sync with Health Connect ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _ActionButton(
                  label: isSyncing ? 'Syncing...' : 'Sync Health',
                  icon: Icons.sync_rounded,
                  color: AppColors.steps,
                  onTap: isSyncing ? null : onSync,
                  isSyncing: isSyncing,
                ),
              ),
            ),
            // ── Set Step Goal ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _ActionButton(
                  label: 'Set Goal',
                  icon: Icons.flag_rounded,
                  color: AppColors.tertiary,
                  onTap: onChangeGoal,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isSyncing;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.isSyncing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isSyncing
                  ? _SyncingIcon(icon: icon, color: color)
                  : Icon(icon, size: 20, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _SyncingIcon({required this.icon, required this.color});

  @override
  State<_SyncingIcon> createState() => _SyncingIconState();
}

class _SyncingIconState extends State<_SyncingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return Icon(widget.icon, size: 20, color: widget.color);
    }
    return RotationTransition(
      turns: _controller,
      child: Icon(widget.icon, size: 20, color: widget.color),
    );
  }
}
