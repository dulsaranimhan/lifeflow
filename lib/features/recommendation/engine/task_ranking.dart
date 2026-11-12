import '../../../core/models/task.dart';

/// Orders tasks by: earliest deadline first (no deadline last), then highest
/// priority, then shorter duration.
int compareTasks(Task a, Task b) {
  final byDeadline = _compareDeadlines(a.deadline, b.deadline);
  if (byDeadline != 0) return byDeadline;

  // TaskPriority is declared high, medium, low, so a lower index wins.
  final byPriority = a.priority.index.compareTo(b.priority.index);
  if (byPriority != 0) return byPriority;

  return a.durationMin.compareTo(b.durationMin);
}

int _compareDeadlines(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

/// Returns a new list sorted with [compareTasks].
List<Task> rankTasks(Iterable<Task> tasks) {
  return tasks.toList()..sort(compareTasks);
}
