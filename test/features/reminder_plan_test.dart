import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/event.dart';
import 'package:lifeflow/core/models/task.dart';
import 'package:lifeflow/features/notifications/domain/reminder_plan.dart';

void main() {
  final now = DateTime(2026, 11, 12, 10);

  test('plans task, event and leave reminders in time order', () {
    final plan = planReminders(
      now: now,
      tasks: [
        Task(id: 't1', title: 'Report', deadline: DateTime(2026, 11, 12, 18)),
        Task(
          id: 't2',
          title: 'Muted',
          deadline: DateTime(2026, 11, 12, 18),
          reminderOn: false,
        ),
        Task(
          id: 't3',
          title: 'Done',
          deadline: DateTime(2026, 11, 12, 18),
          status: TaskStatus.done,
        ),
        Task(id: 't4', title: 'Past', deadline: DateTime(2026, 11, 12, 9)),
        Task(id: 't5', title: 'Far', deadline: DateTime(2026, 12, 30)),
      ],
      events: [
        Event(
          id: 'e1',
          title: 'Lecture',
          startTime: DateTime(2026, 11, 12, 14),
          endTime: DateTime(2026, 11, 12, 16),
          locationName: 'Hall A',
          considerTravel: true,
          reminderMin: 15,
        ),
      ],
      travelMinFor: (_) => 20,
      bufferMin: 10,
      leadMin: 30,
    );

    expect(plan.map((r) => r.title), [
      '🚶 Time to leave',
      '📅 Lecture',
      '⏰ Report',
    ]);
    expect(plan[0].time, DateTime(2026, 11, 12, 13, 30));
    expect(plan[1].time, DateTime(2026, 11, 12, 13, 45));
    expect(plan[2].time, DateTime(2026, 11, 12, 17, 30));
  });

  test('ids are stable and distinct', () {
    expect(reminderId('task:t1'), reminderId('task:t1'));
    expect(reminderId('task:t1'), isNot(reminderId('event:t1')));
    expect(reminderId('task:t1'), greaterThanOrEqualTo(0));
  });

  test('respects the limit', () {
    final plan = planReminders(
      now: now,
      tasks: [
        for (var i = 0; i < 10; i++)
          Task(
            id: '$i',
            title: 'T$i',
            deadline: now.add(Duration(hours: i + 1)),
          ),
      ],
      events: const [],
      travelMinFor: (_) => 0,
      leadMin: 0,
      limit: 3,
    );
    expect(plan.map((r) => r.title), ['⏰ T0', '⏰ T1', '⏰ T2']);
  });
}
