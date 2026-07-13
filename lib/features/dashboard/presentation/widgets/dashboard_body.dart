import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../health_score/presentation/health_score_provider.dart';
import '../dashboard_provider.dart';
import 'greeting_header.dart';
import 'health_score_card.dart';
import 'quick_progress_section.dart';
import 'upcoming_reminder_card.dart';
import 'weekly_summary_bottom_sheet.dart';

class DashboardBody extends StatefulWidget {
  final DashboardProvider provider;
  const DashboardBody({super.key, required this.provider});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting Header ──
            GreetingHeaderClock(
              userName: provider.userName,
              onNotificationTap: () => Navigator.pushNamed(
                context,
                RouteNames.reminderSettings,
              ),
              onAvatarTap: () {
                HapticFeedback.selectionClick();
                provider.setTabIndex(5);
              },
            ),

            const SizedBox(height: 24),

            // ── Card 1: Health Score (Hero) ──
            Consumer<HealthScoreProvider>(
              builder: (context, healthProv, child) {
                return HealthScoreCard(
                  scorePercent: healthProv.todayScore.totalScore.round(),
                  message: healthProv.motivationMessage.isNotEmpty
                      ? healthProv.motivationMessage
                      : healthProv.todayScore.message,
                );
              },
            ),

            const SizedBox(height: 28),

            // ── Card 2: Today's Quick Progress ──
            const SectionHeader(
              title: "Today's Quick Progress",
              subtitle: "Tap cards to open dedicated trackers",
            ),
            const SizedBox(height: 16),
            QuickProgressSection(provider: provider),

            const SizedBox(height: 28),

            // ── Card 3: Upcoming Reminder ──
            const SectionHeader(title: "Upcoming Reminder"),
            const SizedBox(height: 12),
            const UpcomingReminderCard(),

            const SizedBox(height: 28),

            // ── Weekly Summary Button ──
            Center(
              child: FilledButton.icon(
                onPressed: () => showWeeklySummaryBottomSheet(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.analytics_rounded),
                label: const Text(
                  'View Weekly Summary',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
