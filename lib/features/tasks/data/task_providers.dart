import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/task.dart';
import '../../auth/data/auth_providers.dart';
import '../../home/data/home_providers.dart';
import 'task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(Supabase.instance.client);
});

/// All of the signed-in user's tasks (pending and completed).
final tasksProvider = FutureProvider<List<Task>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value(const []);
  return ref.watch(taskRepositoryProvider).fetchAll();
});

/// Changes tasks and refreshes every screen that shows them.
final taskActionsProvider = Provider<TaskActions>(TaskActions.new);

class TaskActions {
  TaskActions(this._ref);

  final Ref _ref;

  TaskRepository get _repo => _ref.read(taskRepositoryProvider);

  Future<void> save(Task task) async {
    if (task.id == null) {
      await _repo.create(task);
    } else {
      await _repo.update(task);
    }
    _refresh();
  }

  Future<void> toggleDone(Task task) async {
    await _repo.setStatus(
      task,
      task.isDone ? TaskStatus.pending : TaskStatus.done,
    );
    _refresh();
  }

  Future<void> delete(Task task) async {
    await _repo.delete(task);
    _refresh();
  }

  void _refresh() {
    _ref.invalidate(tasksProvider);
    _ref.invalidate(homeDataProvider);
  }
}
