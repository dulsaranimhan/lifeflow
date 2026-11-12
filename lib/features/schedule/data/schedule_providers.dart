import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/event.dart';
import '../../../services/travel_time_service.dart';
import '../../events/data/event_providers.dart';
import '../../home/data/home_providers.dart';
import '../../tasks/data/task_providers.dart';
import '../domain/timeline.dart';

/// The day selected in the Calendar week strip.
final selectedDayProvider = NotifierProvider<SelectedDay, DateTime>(
  SelectedDay.new,
);

class SelectedDay extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void select(DateTime day) => state = DateTime(day.year, day.month, day.day);
}

/// Timeline rows for one day (events, leave-by rows and tasks due).
final dayTimelineProvider = FutureProvider.family<List<TimelineItem>, DateTime>(
  (ref, day) async {
    final events = await ref.watch(weekEventsProvider(day).future);
    final tasks = await ref.watch(tasksProvider.future);
    final bufferMin = ref.watch(homeDataProvider).value?.bufferMin ?? 10;
    final travelService = ref.watch(travelTimeServiceProvider);

    final travel = <Event, int>{};
    for (final event in events.where((e) => isSameDay(e.startTime, day))) {
      if (event.considerTravel && event.hasPlace) {
        travel[event] = await travelService.minutesTo(
          lat: event.lat,
          lng: event.lng,
          place: event.locationName,
        );
      }
    }

    return buildTimeline(
      day: day,
      events: events,
      tasks: tasks,
      travelMinFor: (event) => travel[event] ?? 0,
      bufferMin: bufferMin,
    );
  },
);

/// Days in the week of [day] that have at least one event or task due.
final busyDaysProvider = Provider.family<Set<int>, DateTime>((ref, day) {
  final events = ref.watch(weekEventsProvider(day)).value ?? const [];
  final tasks = ref.watch(tasksProvider).value ?? const [];
  final start = startOfWeek(day);
  final busy = <int>{};
  for (var i = 0; i < 7; i++) {
    final d = start.add(Duration(days: i));
    final hasEvent = events.any((e) => isSameDay(e.startTime, d));
    final hasTask = tasks.any(
      (t) => t.deadline != null && isSameDay(t.deadline!, d),
    );
    if (hasEvent || hasTask) busy.add(i);
  }
  return busy;
});
