import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../recommendation/engine/recommendation_engine.dart';
import '../../data/home_providers.dart';

/// The yellow "NEXT ACTION" card: the answer to "What should I do now?".
class NextActionCard extends ConsumerWidget {
  const NextActionCard({super.key, this.onOpen});

  /// Opens the recommendation details screen.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendation = ref.watch(homeRecommendationProvider);

    return switch (recommendation) {
      AsyncData(:final value) => _content(value),
      AsyncError() => const _Layout(
        emoji: '⚠️',
        label: 'NEXT ACTION',
        title: "Couldn't work it out",
        body: 'Pull down to try again.',
      ),
      _ => const _Layout(
        emoji: '⏳',
        label: 'NEXT ACTION',
        title: 'Thinking…',
        body: 'Looking at your tasks and schedule.',
      ),
    };
  }

  Widget _content(RecommendationResult result) {
    return switch (result.kind) {
      RecommendationKind.doTask => _Layout(
        emoji: '🎯',
        label: 'NEXT ACTION',
        title: result.task!.title,
        body: result.reason,
        onOpen: onOpen,
      ),
      RecommendationKind.prepareToLeave => _Layout(
        emoji: '🚶',
        label: 'TIME TO LEAVE',
        title: result.nextEvent?.title ?? 'Get ready to leave',
        body: result.reason,
        onOpen: onOpen,
      ),
      RecommendationKind.takeBreak => _Layout(
        emoji: '☕',
        label: 'TAKE A BREAK',
        title: 'Take a short break',
        body: result.reason,
        onOpen: onOpen,
      ),
      RecommendationKind.allClear => _Layout(
        emoji: '🎉',
        label: 'ALL CLEAR',
        title: "You're all caught up",
        body: result.reason,
      ),
    };
  }
}

class _Layout extends StatelessWidget {
  const _Layout({
    required this.emoji,
    required this.label,
    required this.title,
    required this.body,
    this.onOpen,
  });

  final String emoji;
  final String label;
  final String title;
  final String body;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      key: const Key('next_action_card'),
      color: AppColors.yellowSoft,
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(20, 22, 16, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(
            color: AppColors.surface.withValues(alpha: 0.8),
            child: Text(emoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.ink.withValues(alpha: 0.6),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (onOpen != null) ...[
            const SizedBox(width: 8),
            Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Open recommendation',
                onPressed: onOpen,
                icon: const Icon(Icons.arrow_forward, color: AppColors.ink),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
