import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/event.dart';
import '../../auth/data/auth_providers.dart';
import '../../home/data/home_providers.dart';
import 'event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(Supabase.instance.client);
});

/// Events in the week (Sunday–Saturday) that contains the given day.
final weekEventsProvider = FutureProvider.family<List<Event>, DateTime>((
  ref,
  day,
) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value(const []);
  final start = startOfWeek(day);
  return ref
      .watch(eventRepositoryProvider)
      .fetchBetween(start, start.add(const Duration(days: 7)));
});

/// Events from yesterday until a week from today (notifications and
/// reminders).
final upcomingEventsProvider = FutureProvider<List<Event>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value(const []);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return ref
      .watch(eventRepositoryProvider)
      .fetchBetween(
        today.subtract(const Duration(days: 1)),
        today.add(const Duration(days: 8)),
      );
});

/// Sunday 00:00 of the week containing [day].
DateTime startOfWeek(DateTime day) {
  final date = DateTime(day.year, day.month, day.day);
  return date.subtract(Duration(days: date.weekday % 7));
}

/// Changes events and refreshes every screen that shows them.
final eventActionsProvider = Provider<EventActions>(EventActions.new);

class EventActions {
  EventActions(this._ref);

  final Ref _ref;

  EventRepository get _repo => _ref.read(eventRepositoryProvider);

  Future<void> save(Event event) async {
    if (event.id == null) {
      await _repo.create(event);
    } else {
      await _repo.update(event);
    }
    _refresh();
  }

  Future<void> delete(Event event) async {
    await _repo.delete(event);
    _refresh();
  }

  void _refresh() {
    _ref.invalidate(weekEventsProvider);
    _ref.invalidate(upcomingEventsProvider);
    _ref.invalidate(homeDataProvider);
  }
}
