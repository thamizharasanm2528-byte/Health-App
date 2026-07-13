import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../bmi/presentation/bmi_screen.dart';
import '../../profile/presentation/profile_detail_screen.dart';
import '../../steps/presentation/steps_screen.dart';
import '../../water/presentation/water_screen.dart';
import '../../sleep/presentation/sleep_screen.dart';
import 'dashboard_provider.dart';
import 'widgets/dashboard_body.dart';
import 'widgets/animated_navigation_icon.dart';

/// Dashboard Screen — main hub of the application.
///
/// Contains a [NavigationBar] with 5 tabs. The Dashboard tab
/// shows a scrollable body with greeting, health score,
/// progress cards, reminders, and quick actions.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    // List of screens corresponding to bottom navigation tabs
    final List<Widget> screens = [
      DashboardBody(provider: provider),
      const WaterScreen(),
      const StepsScreen(),
      const BmiScreen(),
      const SleepScreen(),
      const ProfileDetailScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: provider.tabIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: provider.tabIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          provider.setTabIndex(index);
        },
        destinations: [
          NavigationDestination(
            icon: AnimatedNavigationIcon(
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard_rounded,
              isSelected: provider.tabIndex == 0,
            ),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: AnimatedNavigationIcon(
              icon: Icons.water_drop_outlined,
              selectedIcon: Icons.water_drop_rounded,
              isSelected: provider.tabIndex == 1,
            ),
            label: 'Water',
          ),
          NavigationDestination(
            icon: AnimatedNavigationIcon(
              icon: Icons.directions_walk_outlined,
              selectedIcon: Icons.directions_walk_rounded,
              isSelected: provider.tabIndex == 2,
            ),
            label: 'Steps',
          ),
          NavigationDestination(
            icon: AnimatedNavigationIcon(
              icon: Icons.scale_outlined,
              selectedIcon: Icons.scale_rounded,
              isSelected: provider.tabIndex == 3,
            ),
            label: 'BMI',
          ),
          NavigationDestination(
            icon: AnimatedNavigationIcon(
              icon: Icons.bedtime_outlined,
              selectedIcon: Icons.bedtime_rounded,
              isSelected: provider.tabIndex == 4,
            ),
            label: 'Sleep',
          ),
          NavigationDestination(
            icon: AnimatedNavigationIcon(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              isSelected: provider.tabIndex == 5,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
