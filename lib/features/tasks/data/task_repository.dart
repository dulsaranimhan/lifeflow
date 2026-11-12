import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/task.dart';

/// Create, read, update and delete the signed-in user's tasks.
///
/// Row Level Security makes sure users only ever touch their own rows;
/// `user_id` is filled in by the database default (`auth.uid()`).
class TaskRepository {
  TaskRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'tasks';

  Future<List<Task>> fetchAll() async {
    final rows = await _client
        .from(_table)
        .select()
        .order('deadline', ascending: true, nullsFirst: false)
        .order('created_at', ascending: true);
    return rows.map(Task.fromMap).toList();
  }

  Future<Task> create(Task task) async {
    final row = await _client
        .from(_table)
        .insert(task.toMap())
        .select()
        .single();
    return Task.fromMap(row);
  }

  Future<Task> update(Task task) async {
    final id = _requireId(task);
    final map = task.toMap()
      ..remove('id')
      ..remove('user_id')
      ..['updated_at'] = DateTime.now().toUtc().toIso8601String();
    final row = await _client
        .from(_table)
        .update(map)
        .eq('id', id)
        .select()
        .single();
    return Task.fromMap(row);
  }

  Future<void> setStatus(Task task, TaskStatus status) async {
    await _client
        .from(_table)
        .update({
          'status': status.name,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', _requireId(task));
  }

  Future<void> delete(Task task) async {
    await _client.from(_table).delete().eq('id', _requireId(task));
  }

  String _requireId(Task task) {
    final id = task.id;
    if (id == null) throw ArgumentError('Task has not been saved yet');
    return id;
  }
}
