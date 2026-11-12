import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/event.dart';
import '../../../services/travel_time_service.dart';
import '../../events/data/event_providers.dart';
import '../../home/data/home_providers.dart';
import '../../tasks/data/task_providers.dart';
import '../domain/notice.dart';

/// Travel minutes for each upcoming event that needs travel.
final upcomingTravelProvider = FutureProvider<Map<Event, int>>((ref) async {
  final events = await ref.watch(upcomingEventsProvider.future);
  final service = ref.watch(travelTimeServiceProvider);
  final travel = <Event, int>{};
  for (final event in events) {
    if (event.considerTravel && event.hasPlace) {
      travel[event] = await service.minutesTo(
        lat: event.lat,
        lng: event.lng,
        place: event.locationName,
      );
    }
  }
  return travel;
});

/// In-app notifications for yesterday, today and tomorrow.
final noticesProvider = FutureProvider<List<Notice>>((ref) async {
  final tasks = await ref.watch(tasksProvider.future);
  final events = await ref.watch(upcomingEventsProvider.future);
  final travel = await ref.watch(upcomingTravelProvider.future);
  final bufferMin = ref.watch(homeDataProvider).value?.bufferMin ?? 10;
  return buildNotices(
    now: ref.watch(homeClockProvider),
    tasks: tasks,
    events: events,
    travelMinFor: (event) => travel[event] ?? 0,
    bufferMin: bufferMin,
  );
});
