import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/event.dart';

/// Create, read, update and delete the signed-in user's events.
class EventRepository {
  EventRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'events';

  /// Events starting in [from, to), ordered by start time.
  Future<List<Event>> fetchBetween(DateTime from, DateTime to) async {
    final rows = await _client
        .from(_table)
        .select()
        .gte('start_time', from.toUtc().toIso8601String())
        .lt('start_time', to.toUtc().toIso8601String())
        .order('start_time', ascending: true);
    return rows.map(Event.fromMap).toList();
  }

  Future<Event> create(Event event) async {
    final row = await _client
        .from(_table)
        .insert(event.toMap())
        .select()
        .single();
    return Event.fromMap(row);
  }

  Future<Event> update(Event event) async {
    final id = _requireId(event);
    final map = event.toMap()
      ..remove('id')
      ..remove('user_id')
      ..['updated_at'] = DateTime.now().toUtc().toIso8601String();
    final row = await _client
        .from(_table)
        .update(map)
        .eq('id', id)
        .select()
        .single();
    return Event.fromMap(row);
  }

  Future<void> delete(Event event) async {
    await _client.from(_table).delete().eq('id', _requireId(event));
  }

  String _requireId(Event event) {
    final id = event.id;
    if (id == null) throw ArgumentError('Event has not been saved yet');
    return id;
  }
}
