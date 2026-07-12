import 'dart:async';
import 'package:flutter/material.dart';

/// Dashboard greeting header replacing the standard AppBar.
///
/// Displays a time-based greeting, user name, formatted date,
/// notification icon, and a profile avatar circle.
class GreetingHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final String date;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  const GreetingHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.date,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(
          children: [
            // ── Greeting text ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting,',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
  
            // ── Notification bell ──
            IconButton(
              onPressed: onNotificationTap,
              icon: Badge(
                smallSize: 8,
                child: Icon(
                  Icons.notifications_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
  
            const SizedBox(width: 4),
  
            // ── Avatar ──
            GestureDetector(
              onTap: onAvatarTap,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GreetingHeaderClock extends StatefulWidget {
  final String userName;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  const GreetingHeaderClock({
    super.key,
    required this.userName,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  @override
  State<GreetingHeaderClock> createState() => _GreetingHeaderClockState();
}

class _GreetingHeaderClockState extends State<GreetingHeaderClock> {
  Timer? _timer;
  late String _greeting;
  late String _date;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _updateTime();
        });
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    _date = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GreetingHeader(
      greeting: _greeting,
      userName: widget.userName,
      date: _date,
      onNotificationTap: widget.onNotificationTap,
      onAvatarTap: widget.onAvatarTap,
    );
  }
}

