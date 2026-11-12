import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/event.dart';
import '../../../core/models/profile.dart';
import '../../../core/models/task.dart';
import 'home_data.dart';

/// Read-only queries used by the Home screen.
///
/// Creating and editing tasks/events lives in the tasks and events features.
class HomeRepository {
  HomeRepository(this._client);

  final SupabaseClient _client;

  Future<HomeData> load(String userId, DateTime now) async {
    final results = await Future.wait([
      _profile(userId),
      _pendingTasks(userId),
      _eventsOn(userId, now),
    ]);
    return HomeData(
      profile: results[0] as Profile?,
      pendingTasks: results[1] as List<Task>,
      eventsToday: results[2] as List<Event>,
    );
  }

  Future<Profile?> _profile(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : Profile.fromMap(row);
  }

  Future<List<Task>> _pendingTasks(String userId) async {
    final rows = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('status', TaskStatus.pending.name)
        .order('deadline', ascending: true, nullsFirst: false);
    return rows.map(Task.fromMap).toList();
  }

  Future<List<Event>> _eventsOn(String userId, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await _client
        .from('events')
        .select()
        .eq('user_id', userId)
        .gte('start_time', start.toUtc().toIso8601String())
        .lt('start_time', end.toUtc().toIso8601String())
        .order('start_time', ascending: true);
    return rows.map(Event.fromMap).toList();
  }
}
