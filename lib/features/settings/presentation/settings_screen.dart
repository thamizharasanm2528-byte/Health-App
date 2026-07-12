import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/notifications/notification_service.dart';
import '../../../core/services/notifications/notification_permission_service.dart';
import '../../../core/routing/route_names.dart';
import '../../steps/data/health_service.dart';
import 'settings_provider.dart';
import 'theme_provider.dart';
import 'units_provider.dart';
import 'widgets/settings_group.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifPermission = false;
  bool _healthPermission = false;
  final _healthService = HealthService();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final notif = await NotificationService.instance.permissionService.getStatus();
    final health = await _healthService.hasPermissions();
    if (mounted) {
      setState(() {
        _notifPermission = notif == NotificationPermissionStatus.granted;
        _healthPermission = health;
      });
    }
  }

  Future<void> _requestNotifPermission() async {
    final granted = await NotificationService.instance.permissionService.requestPermission();
    setState(() => _notifPermission = granted);
  }

  Future<void> _requestHealthPermission() async {
    final granted = await _healthService.requestPermissions();
    setState(() => _healthPermission = granted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final unitsProv = context.watch<UnitsProvider>();
    
    final appSettings = settingsProv.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [


          // ── ALARMS & REMINDERS ──
          SettingsGroup(
            title: 'Alarms & Reminders',
            children: [
              SettingsTile(
                icon: Icons.alarm_rounded,
                title: 'Wake-up Alarm Settings',
                subtitle: 'Configure daily wake-up alarm, repeat days & sound',
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.alarm);
                },
              ),
              SettingsTile(
                icon: Icons.notifications_active_rounded,
                title: 'Central Reminder Settings',
                subtitle: 'Configure Wake, Water, & Bedtime reminders',
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.reminderSettings);
                },
              ),
            ],
          ),



          // ── APPEARANCE ──
          SettingsGroup(
            title: 'Appearance',
            children: [
              SettingsTile(
                icon: Icons.palette_rounded,
                title: 'Theme Mode',
                subtitle: themeProv.themeModeStr.toUpperCase(),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('Choose Theme'),
                      children: ['system', 'light', 'dark'].map((m) {
                        return SimpleDialogOption(
                          onPressed: () {
                            themeProv.setThemeMode(m);
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(m.toUpperCase()),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.color_lens_rounded,
                title: 'Accent Color',
                subtitle: themeProv.accentColor[0].toUpperCase() + themeProv.accentColor.substring(1),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accentColorValue(themeProv.accentColor),
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('Choose Accent Color'),
                      children: [
                        _buildAccentOption(context, themeProv, 'green', const Color(0xFF0F9F68)),
                        _buildAccentOption(context, themeProv, 'blue', const Color(0xFF3B82F6)),
                        _buildAccentOption(context, themeProv, 'purple', const Color(0xFF8B5CF6)),
                        _buildAccentOption(context, themeProv, 'teal', const Color(0xFF14B8A6)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // ── UNITS ──
          SettingsGroup(
            title: 'Units of Measurement',
            children: [
              SettingsTile(
                icon: Icons.straighten_rounded,
                title: 'Height Unit',
                subtitle: appSettings.heightUnit == 'ft' ? 'Feet & Inches' : 'Centimeters',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('Choose Height Unit'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () {
                            unitsProv.setHeightUnit('cm');
                            Navigator.of(context).pop();
                          },
                          child: const Text('Centimeters (cm)'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            unitsProv.setHeightUnit('ft');
                            Navigator.of(context).pop();
                          },
                          child: const Text('Feet & Inches (ft)'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.scale_rounded,
                title: 'Weight Unit',
                subtitle: appSettings.weightUnit == 'lbs' ? 'Pounds (lbs)' : 'Kilograms (kg)',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('Choose Weight Unit'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () {
                            unitsProv.setWeightUnit('kg');
                            Navigator.of(context).pop();
                          },
                          child: const Text('Kilograms (kg)'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            unitsProv.setWeightUnit('lbs');
                            Navigator.of(context).pop();
                          },
                          child: const Text('Pounds (lbs)'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.local_drink_rounded,
                title: 'Water Unit',
                subtitle: appSettings.waterUnit == 'liters'
                    ? 'Litres (L)'
                    : (appSettings.waterUnit == 'oz' ? 'Fluid Ounces (fl oz)' : 'Millilitres (ml)'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('Choose Water Unit'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () {
                            unitsProv.setWaterUnit('ml');
                            Navigator.of(context).pop();
                          },
                          child: const Text('Millilitres (ml)'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            unitsProv.setWaterUnit('liters');
                            Navigator.of(context).pop();
                          },
                          child: const Text('Litres (L)'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            unitsProv.setWaterUnit('oz');
                            Navigator.of(context).pop();
                          },
                          child: const Text('Fluid Ounces (fl oz)'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // ── PRIVACY & PERMISSIONS ──
          SettingsGroup(
            title: 'Privacy & Permissions',
            children: [
              SettingsTile(
                icon: Icons.security_rounded,
                title: 'Notification Access',
                subtitle: _notifPermission ? 'Granted' : 'Denied / Disabled',
                trailing: _notifPermission
                    ? const Icon(Icons.check_circle_outline_rounded, color: Colors.green)
                    : TextButton(
                        onPressed: _requestNotifPermission,
                        child: const Text('Request'),
                      ),
              ),
              SettingsTile(
                icon: Icons.favorite_border_rounded,
                title: 'Health Core Services Access',
                subtitle: _healthPermission ? 'Granted' : 'Denied / Disabled',
                trailing: _healthPermission
                    ? const Icon(Icons.check_circle_outline_rounded, color: Colors.green)
                    : TextButton(
                        onPressed: _requestHealthPermission,
                        child: const Text('Request'),
                      ),
              ),
            ],
          ),

          // ── DATA MANAGEMENT ──
          SettingsGroup(
            title: 'Data Management',
            children: [
              SettingsTile(
                icon: Icons.delete_forever_rounded,
                title: 'Clear All Data',
                subtitle: 'Destructive: Wipe all local history logs',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Wipe Database?'),
                      content: const Text(
                          'Are you sure you want to permanently clear all logs, goals, and calculations? This action is irreversible.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                          onPressed: () async {
                            await settingsProv.clearAllData();
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All data cleared successfully.')),
                            );
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // ── ABOUT ──
          SettingsGroup(
            title: 'About',
            children: [
              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About Health Companion',
                subtitle: 'Version, developer, privacy & terms',
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.about);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }



  Color _accentColorValue(String name) {
    switch (name) {
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'purple':
        return const Color(0xFF8B5CF6);
      case 'teal':
        return const Color(0xFF14B8A6);
      case 'green':
      default:
        return const Color(0xFF0F9F68);
    }
  }

  Widget _buildAccentOption(BuildContext context, ThemeProvider themeProv, String name, Color color) {
    final isSelected = themeProv.accentColor == name;
    return SimpleDialogOption(
      onPressed: () {
        themeProv.setAccentColor(name);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              name[0].toUpperCase() + name.substring(1),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
