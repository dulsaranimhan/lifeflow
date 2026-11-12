import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/task.dart';
import 'package:lifeflow/features/recommendation/engine/snooze.dart';

void main() {
  final now = DateTime(2026, 11, 12, 10);
  const a = Task(id: 'a', title: 'A');
  const b = Task(id: 'b', title: 'B');
  const unsaved = Task(title: 'Unsaved');

  test('hides tasks snoozed until a future time', () {
    final result = withoutSnoozed(
      [a, b, unsaved],
      {'a': now.add(const Duration(minutes: 30))},
      now,
    );
    expect(result.map((t) => t.title), ['B', 'Unsaved']);
  });

  test('shows tasks again once the snooze has expired', () {
    final result = withoutSnoozed(
      [a, b],
      {'a': now.subtract(const Duration(minutes: 1))},
      now,
    );
    expect(result, hasLength(2));
  });
}
