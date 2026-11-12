import '../../../core/models/task.dart';

/// Pending tasks that fit into the free time.
///
/// When [freeMinutes] is null the free time is open-ended (no upcoming event),
/// so every pending task is feasible.
List<Task> feasibleTasks(List<Task> tasks, int? freeMinutes) {
  return tasks
      .where((task) => task.status == TaskStatus.pending)
      .where((task) => freeMinutes == null || task.durationMin <= freeMinutes)
      .toList();
}
