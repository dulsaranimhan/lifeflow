import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../events/data/event_providers.dart';
import '../../tasks/data/task_providers.dart';
import '../data/schedule_providers.dart';
import '../domain/timeline.dart';
import 'widgets/timeline_row.dart';
import 'widgets/week_strip.dart';

/// 06 – Calendar / schedule (S07).
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  String _title(DateTime day) {
    final today = DateTime.now();
    if (isSameDay(day, today)) return 'Today';
    if (isSameDay(day, today.add(const Duration(days: 1)))) return 'Tomorrow';
    if (isSameDay(day, today.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('EEE, d MMM').format(day);
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final day = ref.read(selectedDayProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: DateTime(day.year - 1),
      lastDate: DateTime(day.year + 5),
    );
    if (picked != null) ref.read(selectedDayProvider.notifier).select(picked);
  }

  void _open(BuildContext context, TimelineItem item) {
    if (item.event != null) {
      context.push(AppRoutes.editEvent, extra: item.event);
    } else if (item.task != null) {
      context.push(AppRoutes.editTask, extra: item.task);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final day = ref.watch(selectedDayProvider);
    final timeline = ref.watch(dayTimelineProvider(day));
    final busy = ref.watch(busyDaysProvider(day));
    final highlight = isSameDay(day, DateTime.now())
        ? highlightIndex(timeline.value ?? const [], DateTime.now())
        : null;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        heroTag: 'add_event',
        tooltip: 'Add event',
        onPressed: () => context.push(AppRoutes.newEvent, extra: day),
        child: const Icon(Icons.add, size: 36),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(weekEventsProvider);
            ref.invalidate(tasksProvider);
            await ref.read(dayTimelineProvider(day).future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
            children: [
              const AppTopBar(),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_title(day), style: theme.textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text(
                          "Let's make it a good day 💛",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.muted,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(16),
                    child: IconButton(
                      tooltip: 'Pick a date',
                      iconSize: 26,
                      padding: const EdgeInsets.all(14),
                      onPressed: () => _pickDate(context, ref),
                      icon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              WeekStrip(
                selected: day,
                busyDays: busy,
                onSelect: ref.read(selectedDayProvider.notifier).select,
              ),
              const SizedBox(height: 24),
              ...switch (timeline) {
                AsyncData(:final value) when value.isEmpty => [
                  _Empty(
                    text:
                        'Nothing planned for this day.\n'
                        'Tap + to add an event.',
                  ),
                ],
                AsyncData(:final value) => [
                  for (var i = 0; i < value.length; i++)
                    TimelineRow(
                      item: value[i],
                      highlighted: i == highlight,
                      isLast: i == value.length - 1,
                      onTap: () => _open(context, value[i]),
                    ),
                ],
                AsyncError() => [
                  _Empty(
                    text: "Couldn't load your schedule. Pull down to retry.",
                  ),
                ],
                _ => [
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: AppColors.muted),
      ),
    );
  }
}
