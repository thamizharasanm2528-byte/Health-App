import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'health_score_provider.dart';

class HealthScoreScreen extends StatelessWidget {
  const HealthScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<HealthScoreProvider>();
    final score = provider.todayScore;

    Color levelColor;
    if (score.totalScore >= 90) {
      levelColor = Colors.green;
    } else if (score.totalScore >= 75) {
      levelColor = Colors.blue;
    } else if (score.totalScore >= 60) {
      levelColor = Colors.orange;
    } else if (score.totalScore >= 40) {
      levelColor = Colors.amber;
    } else {
      levelColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Health Score'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // ── Premium Score Ring Card ──
          Card(
            elevation: 2,
            shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: score.totalScore / 100.0,
                          strokeWidth: 14,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          color: levelColor,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${score.totalScore.round()}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: levelColor,
                            ),
                          ),
                          Text(
                            'Score',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    score.level.toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: levelColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      score.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Score Breakdown ──
          Text(
            'SCORE BREAKDOWN',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                _buildBreakdownTile(context, '💧 Water Goal', score.waterScore, 25),
                const Divider(height: 1),
                _buildBreakdownTile(context, '🚶 Steps Goal', score.stepScore, 25),
                const Divider(height: 1),
                _buildBreakdownTile(context, '😴 Sleep Target', score.sleepScore, 25),
                const Divider(height: 1),
                _buildBreakdownTile(context, '⚖ BMI / Weight Progress', score.bmiScore, 25),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Motivation Card ──
          if (provider.motivationMessage.isNotEmpty) ...[
            Text(
              'MOTIVATION INSIGHT',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.08),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.star_rounded, color: theme.colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        provider.motivationMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBreakdownTile(BuildContext context, String title, double val, double max) {
    final theme = Theme.of(context);
    final percent = val / max;
    return ListTile(
      title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: percent >= 0.8
                ? Colors.green
                : (percent >= 0.5 ? Colors.orange : Colors.red),
          ),
        ),
      ),
      trailing: Text(
        '${val.round()} / ${max.round()}',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
