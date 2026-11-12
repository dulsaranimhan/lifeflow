import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/task.dart';
import 'package:lifeflow/features/tasks/domain/task_list_filter.dart';

void main() {
  final now = DateTime(2026, 11, 12, 10);
  final tasks = [
    Task(
      title: 'Write report',
      deadline: DateTime(2026, 11, 13, 9),
      category: TaskCategory.work,
      priority: TaskPriority.high,
    ),
    Task(
      title: 'Yoga',
      deadline: DateTime(2026, 11, 12, 18),
      category: TaskCategory.health,
    ),
    const Task(
      title: 'Read book',
      category: TaskCategory.learning,
      notes: 'chapter on databases',
    ),
    Task(
      title: 'Old task',
      deadline: DateTime(2026, 11, 1),
      status: TaskStatus.done,
    ),
  ];

  test('pending tab is ranked like the engine', () {
    final result = visibleTasks(tasks, completed: false);
    expect(result.map((t) => t.title), ['Yoga', 'Write report', 'Read book']);
  });

  test('completed tab only shows done tasks', () {
    expect(visibleTasks(tasks, completed: true).single.title, 'Old task');
  });

  test('search matches title and notes', () {
    expect(
      visibleTasks(tasks, completed: false, query: 'DATABASES').single.title,
      'Read book',
    );
  });

  test('filters by category and priority', () {
    final work = TaskFilter.options.firstWhere((f) => f.label == 'Work');
    final high = TaskFilter.options.firstWhere(
      (f) => f.label == 'High priority',
    );
    expect(
      visibleTasks(tasks, completed: false, filter: work).single.title,
      'Write report',
    );
    expect(
      visibleTasks(tasks, completed: false, filter: high).single.title,
      'Write report',
    );
  });

  test('due labels', () {
    expect(dueLabel(null, now), '');
    expect(dueLabel(DateTime(2026, 11, 12, 18), now), 'Today');
    expect(dueLabel(DateTime(2026, 11, 12, 8), now), 'Overdue');
    expect(dueLabel(DateTime(2026, 11, 13, 9), now), 'Tomorrow');
    expect(dueLabel(DateTime(2026, 11, 16), now), 'Nov 16');
    expect(dueLabel(DateTime(2026, 11, 10), now), 'Overdue');
  });
}
