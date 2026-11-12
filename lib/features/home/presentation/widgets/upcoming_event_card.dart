import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/event.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../recommendation/engine/reason_text.dart';
import '../../../recommendation/engine/time_window.dart';
import '../../data/home_providers.dart';

/// White "UPCOMING EVENT" card with the leave-by time.
class UpcomingEventCard extends ConsumerWidget {
  const UpcomingEventCard({super.key, required this.bufferMin, this.onOpen});

  final int bufferMin;
  final ValueChanged<Event>? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final event = ref.watch(homeNextEventProvider);
    final travelMin = ref.watch(homeTravelMinutesProvider).value ?? 0;

    final String title;
    final String? time;
    final String detail;
    if (event == null) {
      title = 'No more events today';
      time = null;
      detail = 'Your schedule is free';
    } else {
      final travel = effectiveTravelMin(event, travelMin);
      final leave = leaveTimeFor(
        event,
        travelMin: travelMin,
        bufferMin: bufferMin,
      );
      title = event.title;
      time = formatClock(event.startTime);
      detail = travel > 0
          ? 'Leave by ${formatClock(leave)} · $travel min travel'
          : [
              'Leave by ${formatClock(leave)}',
              if (event.locationName?.isNotEmpty ?? false) event.locationName!,
            ].join(' · ');
    }

    return SoftCard(
      key: const Key('upcoming_event_card'),
      onTap: event == null || onOpen == null ? null : () => onOpen!(event),
      child: Row(
        children: [
          const IconBox(child: Text('📅', style: TextStyle(fontSize: 28))),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'UPCOMING EVENT',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.muted,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    if (time != null)
                      Text(time, style: theme.textTheme.titleSmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
