import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/task.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/square_back_button.dart';
import '../../home/data/home_providers.dart';
import '../../tasks/domain/task_list_filter.dart';
import '../../tasks/presentation/widgets/task_style.dart';
import '../data/recommendation_providers.dart';
import '../engine/reason_text.dart';
import '../engine/recommendation_engine.dart';

/// 08 – "Recommended for you": details of the Home recommendation.
class RecommendationScreen extends ConsumerStatefulWidget {
  const RecommendationScreen({super.key});

  @override
  ConsumerState<RecommendationScreen> createState() =>
      _RecommendationScreenState();
}

class _RecommendationScreenState extends ConsumerState<RecommendationScreen> {
  /// An alternative the user picked instead of the suggested task.
  Task? _chosen;
  bool _busy = false;

  Future<void> _respond(Future<void> Function() action, String message) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(message)));
      if (mounted) context.pop();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't save that. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recommendation = ref.watch(homeRecommendationProvider);
    final now = ref.watch(homeClockProvider);

    return Scaffold(
      body: SafeArea(
        child: switch (recommendation) {
          AsyncData(:final value) => _content(context, value, now),
          AsyncError() => const Center(
            child: Text("Couldn't load your recommendation."),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
      bottomNavigationBar: recommendation.value == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _actions(recommendation.value!, theme),
            ),
    );
  }

  Widget _content(
    BuildContext context,
    RecommendationResult result,
    DateTime now,
  ) {
    final theme = Theme.of(context);
    final task = result.kind == RecommendationKind.doTask
        ? (_chosen ?? result.task!)
        : null;
    final alternatives = [
      if (_chosen != null && result.task != null) result.task!,
      ...result.alternatives.where((t) => t.id != _chosen?.id),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            const SquareBackButton(color: AppColors.iconBox),
            const Spacer(),
            Text('LifeFlow', style: theme.textTheme.titleMedium),
            const SizedBox(width: 4),
            const CircleAvatar(radius: 6, backgroundColor: AppColors.yellow),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Recommended\nfor you',
          style: theme.textTheme.headlineLarge?.copyWith(height: 1.15),
        ),
        const SizedBox(height: 8),
        Text(
          'A small step now can make\nyour day feel a lot lighter.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.muted,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 20),
        _HeroCard(result: result, task: task, now: now),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why this helps', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                _why(result, task, now),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        if (task != null && alternatives.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Try an alternative', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          for (final alt in alternatives)
            _AlternativeTile(
              task: alt,
              now: now,
              onTap: () => setState(
                () => _chosen = alt.id == result.task?.id ? null : alt,
              ),
            ),
        ],
      ],
    );
  }

  String _why(RecommendationResult result, Task? task, DateTime now) {
    if (task == null) {
      return result.reason.split(' · ').join('. ').replaceAll('..', '.');
    }
    final free = result.freeMinutes;
    final parts = [
      '${describeDeadline(task.deadline, now)} and marked '
          '${describePriority(task.priority).toLowerCase()}.',
      free == null
          ? 'You have no more events today, so this is a good time to '
                'focus on it.'
          : 'You have ${formatMinutes(free)} before you need to leave, and '
                'this takes about ${formatMinutes(task.durationMin)} – it fits.',
      if (_chosen == null)
        'Of everything that fits, it is the most urgent one.',
    ];
    return parts.join(' ');
  }

  Widget _actions(RecommendationResult result, ThemeData theme) {
    final actions = ref.read(recommendationActionsProvider);
    final task = result.kind == RecommendationKind.doTask
        ? (_chosen ?? result.task!)
        : null;

    if (task == null) {
      return FilledButton(
        onPressed: () => context.pop(),
        child: const Text('Got it'),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(
          key: const Key('recommendation_start'),
          onPressed: _busy
              ? null
              : () => _respond(
                  () => actions.start(result, task),
                  "Let's go! Focus on “${task.title}”.",
                ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Start Now'),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                icon: Icons.schedule,
                label: 'Postpone',
                onPressed: _busy
                    ? null
                    : () => _respond(
                        () => actions.postpone(result, task),
                        'Postponed for 30 minutes.',
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SecondaryButton(
                icon: Icons.close,
                label: 'Ignore',
                onPressed: _busy
                    ? null
                    : () => _respond(
                        () => actions.ignore(result, task),
                        'Okay, I will suggest something else.',
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.result,
    required this.task,
    required this.now,
  });

  final RecommendationResult result;
  final Task? task;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (emoji, title) = switch (result.kind) {
      RecommendationKind.doTask => ('🎯', task!.title),
      RecommendationKind.prepareToLeave => (
        '🚶',
        'Get ready to leave for ${result.nextEvent?.title ?? 'your event'}',
      ),
      RecommendationKind.takeBreak => ('☕', 'Take a short break'),
      RecommendationKind.allClear => ('🎉', "You're all caught up"),
    };

    return SoftCard(
      color: AppColors.yellowSoft,
      padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBox(
                  size: 56,
                  color: AppColors.surface,
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(height: 16),
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    if (task != null) ...[
                      _Meta(
                        icon: Icons.schedule,
                        text: formatMinutes(task!.durationMin),
                      ),
                      _Meta(
                        icon: Icons.flag_outlined,
                        text: '${task!.priority.label} priority',
                      ),
                    ],
                    if (result.leaveTime != null)
                      _Meta(
                        icon: Icons.directions_walk,
                        text: 'Leave ${formatClock(result.leaveTime!)}',
                      ),
                  ],
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/recommendation_illustration.png',
            width: 110,
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _AlternativeTile extends StatelessWidget {
  const _AlternativeTile({
    required this.task,
    required this.now,
    required this.onTap,
  });

  final Task task;
  final DateTime now;
  final VoidCallback onTap;

  String get _emoji => switch (task.category) {
    TaskCategory.work => '💼',
    TaskCategory.personal => '🏠',
    TaskCategory.health => '💪',
    TaskCategory.learning => '📚',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = dueLabel(task.deadline, now);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconBox(
                  size: 48,
                  color: AppColors.surface,
                  child: Text(_emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        [
                          if (due.isNotEmpty) due,
                          task.category.label,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.iconBox,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    formatMinutes(task.durationMin).replaceAll('m', ' min'),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.field,
        foregroundColor: AppColors.ink,
      ),
    );
  }
}
