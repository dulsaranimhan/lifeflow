import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/travel_time_service.dart';
import '../../auth/data/auth_providers.dart';
import '../../recommendation/data/recommendation_providers.dart';
import '../../recommendation/engine/recommendation_engine.dart';
import '../../recommendation/engine/snooze.dart';
import 'home_data.dart';
import 'home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(Supabase.instance.client);
});

/// The "now" used for recommendations. Call [HomeClock.tick] to recalculate
/// without reloading data from Supabase.
final homeClockProvider = NotifierProvider<HomeClock, DateTime>(HomeClock.new);

class HomeClock extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void tick() => state = DateTime.now();
}

/// Tasks, today's events and profile for the signed-in user.
final homeDataProvider = FutureProvider<HomeData>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw StateError('Not signed in');
  return ref.watch(homeRepositoryProvider).load(user.id, DateTime.now());
});

/// The next event today, recalculated whenever the clock ticks.
final homeNextEventProvider = Provider((ref) {
  final data = ref.watch(homeDataProvider).value;
  return data?.nextEvent(ref.watch(homeClockProvider));
});

/// Travel minutes to the next event (0 when travel does not apply).
final homeTravelMinutesProvider = FutureProvider<int>((ref) {
  final event = ref.watch(homeNextEventProvider);
  if (event == null || !event.considerTravel || !event.hasPlace) {
    return Future.value(0);
  }
  return ref
      .watch(travelTimeServiceProvider)
      .minutesTo(lat: event.lat, lng: event.lng, place: event.locationName);
});

/// "What should I do now?" for the Home screen.
final homeRecommendationProvider = FutureProvider<RecommendationResult>((
  ref,
) async {
  final data = await ref.watch(homeDataProvider.future);
  final travelMin = await ref.watch(homeTravelMinutesProvider.future);
  final now = ref.watch(homeClockProvider);
  final snoozed = ref.watch(snoozedTasksProvider);
  return recommend(
    now: now,
    tasks: withoutSnoozed(data.pendingTasks, snoozed, now),
    nextEvent: data.nextEvent(now),
    travelMin: travelMin,
    bufferMin: data.bufferMin,
  );
});
