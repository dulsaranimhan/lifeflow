import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../recommendation/engine/reason_text.dart';
import '../../../recommendation/engine/recommendation_engine.dart';
import '../../data/home_providers.dart';

/// The highlighted "WHAT SHOULD I DO NOW?" card.
class RecommendationCard extends ConsumerWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendation = ref.watch(homeRecommendationProvider);
    final now = ref.watch(homeClockProvider);

    return switch (recommendation) {
      AsyncData(:final value) => _Card(result: value, now: now),
      AsyncError() => const _Shell(
        icon: Icons.error_outline,
        title: "Couldn't work out a suggestion",
        body: 'Pull down to try again.',
      ),
      _ => const _Shell(
        icon: Icons.hourglass_empty,
        title: 'Thinking…',
        body: 'Looking at your tasks and schedule.',
      ),
    };
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.result, required this.now});

  final RecommendationResult result;
  final DateTime now;

  void _todo(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what is coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    switch (result.kind) {
      case RecommendationKind.doTask:
        final task = result.task!;
        final leave = result.leaveTime;
        final window = leave == null
            ? 'Now · ${formatMinutes(task.durationMin)}'
            : 'Now → ${formatClock(leave)} · ${formatMinutes(task.durationMin)}';
        final alternatives = result.alternatives.map((t) => t.title).join(', ');
        return _Shell(
          icon: Icons.play_circle_outline,
          title: task.title,
          subtitle: window,
          body: result.reason,
          footer: alternatives.isEmpty ? null : 'Next up: $alternatives',
          actions: [
            Expanded(
              child: FilledButton(
                key: const Key('recommendation_start'),
                // TODO(esandu): open S03 Recommendation screen.
                onPressed: () => _todo(context, 'Start'),
                child: const Text('Start'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                // TODO(esandu): open task details.
                onPressed: () => _todo(context, 'Task details'),
                child: const Text('View details'),
              ),
            ),
          ],
        );
      case RecommendationKind.prepareToLeave:
        return _Shell(
          icon: Icons.directions_walk,
          title: 'Get ready to leave',
          subtitle: result.nextEvent?.title,
          body: result.reason,
          urgent: true,
        );
      case RecommendationKind.takeBreak:
        return _Shell(
          icon: Icons.free_breakfast_outlined,
          title: 'Take a short break',
          body: result.reason,
        );
      case RecommendationKind.allClear:
        return _Shell(
          icon: Icons.celebration_outlined,
          title: 'All clear!',
          body: result.reason,
        );
    }
  }
}

class _Shell extends StatelessWidget {
  const _Shell({
    required this.icon,
    required this.title,
    required this.body,
    this.subtitle,
    this.footer,
    this.actions,
    this.urgent = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String body;
  final String? footer;
  final List<Widget>? actions;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = urgent ? scheme.errorContainer : scheme.primary;
    final foreground = urgent ? scheme.onErrorContainer : scheme.onPrimary;

    return Card(
      color: background,
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WHAT SHOULD I DO NOW?',
              style: theme.textTheme.labelMedium?.copyWith(
                color: foreground.withValues(alpha: 0.8),
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(icon, color: foreground, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.titleSmall?.copyWith(color: foreground),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
            ),
            if (footer != null) ...[
              const SizedBox(height: 8),
              Text(
                footer!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foreground.withValues(alpha: 0.8),
                ),
              ),
            ],
            if (actions != null) ...[
              const SizedBox(height: 16),
              Theme(
                data: theme.copyWith(
                  filledButtonTheme: FilledButtonThemeData(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.secondary,
                      foregroundColor: scheme.onSecondary,
                    ),
                  ),
                  outlinedButtonTheme: OutlinedButtonThemeData(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: foreground,
                      side: BorderSide(color: foreground),
                    ),
                  ),
                ),
                child: Row(children: actions!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
