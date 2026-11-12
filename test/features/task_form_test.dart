import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/task.dart';
import 'package:lifeflow/core/theme/app_theme.dart';
import 'package:lifeflow/features/tasks/presentation/task_form_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(theme: AppTheme.light, home: child),
);

void main() {
  testWidgets('empty title shows a validation error', (tester) async {
    await tester.pumpWidget(_wrap(const TaskFormScreen()));

    expect(find.text('Add Task'), findsOneWidget);
    final save = find.byKey(const Key('task_save'));
    await tester.scrollUntilVisible(
      save,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(save);
    await tester.pump();

    expect(find.text('Please enter a task title'), findsOneWidget);
  });

  testWidgets('edit mode is pre-filled', (tester) async {
    final task = Task(
      id: 't1',
      title: 'Lab report',
      deadline: DateTime(2026, 11, 20, 23, 59),
      durationMin: 90,
      priority: TaskPriority.high,
      category: TaskCategory.learning,
      notes: 'Section 3',
    );
    await tester.pumpWidget(_wrap(TaskFormScreen(task: task)));

    expect(find.text('Edit Task'), findsOneWidget);
    expect(find.text('Lab report'), findsOneWidget);
    expect(find.text('Fri, Nov 20, 2026'), findsOneWidget);
    expect(find.text('1.5 hours'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Section 3'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Section 3'), findsOneWidget);
  });

  test('duration labels', () {
    expect(durationLabel(30), '30 min');
    expect(durationLabel(60), '1 hour');
    expect(durationLabel(120), '2 hours');
    expect(durationLabel(90), '1.5 hours');
  });
}
