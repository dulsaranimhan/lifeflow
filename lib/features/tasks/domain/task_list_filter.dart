import 'package:intl/intl.dart';

import '../../../core/models/task.dart';
import '../../recommendation/engine/task_ranking.dart';

/// One option of the "All ▾" filter on the Tasks screen.
class TaskFilter {
  const TaskFilter._(this.label, {this.category, this.priority});

  final String label;
  final TaskCategory? category;
  final TaskPriority? priority;

  static const all = TaskFilter._('All');

  static final options = <TaskFilter>[
    all,
    for (final c in TaskCategory.values)
      TaskFilter._(_capitalize(c.name), category: c),
    for (final p in TaskPriority.values)
      TaskFilter._('${_capitalize(p.name)} priority', priority: p),
  ];

  bool matches(Task task) =>
      (category == null || task.category == category) &&
      (priority == null || task.priority == priority);

  @override
  bool operator ==(Object other) =>
      other is TaskFilter &&
      other.category == category &&
      other.priority == priority;

  @override
  int get hashCode => Object.hash(category, priority);
}

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

/// Tasks for one tab of the Tasks screen.
///
/// Pending tasks use the same order as the recommendation engine; completed
/// tasks show the most recent deadline first.
List<Task> visibleTasks(
  List<Task> tasks, {
  required bool completed,
  String query = '',
  TaskFilter filter = TaskFilter.all,
}) {
  final q = query.trim().toLowerCase();
  final matching = tasks.where(
    (t) =>
        t.isDone == completed &&
        filter.matches(t) &&
        (q.isEmpty ||
            t.title.toLowerCase().contains(q) ||
            (t.notes?.toLowerCase().contains(q) ?? false)),
  );
  if (!completed) return rankTasks(matching);
  return matching.toList()..sort((a, b) {
    final da = a.deadline, db = b.deadline;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  });
}

/// "Today", "Tomorrow", "Overdue", "Apr 16" or "" when there is no deadline.
String dueLabel(DateTime? deadline, DateTime now) {
  if (deadline == null) return '';
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(deadline.year, deadline.month, deadline.day);
  final diff = day.difference(today).inDays;
  if (diff < 0) return 'Overdue';
  if (diff == 0) return deadline.isBefore(now) ? 'Overdue' : 'Today';
  if (diff == 1) return 'Tomorrow';
  return DateFormat('MMM d').format(deadline);
}
