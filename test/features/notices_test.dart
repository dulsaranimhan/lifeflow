import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/event.dart';
import 'package:lifeflow/core/models/task.dart';
import 'package:lifeflow/features/notifications/domain/notice.dart';

void main() {
  final now = DateTime(2026, 11, 12, 10);
  final tasks = [
    Task(title: 'Report', deadline: DateTime(2026, 11, 12, 23, 59)),
    Task(title: 'Slides', deadline: DateTime(2026, 11, 13, 9)),
    Task(title: 'Late', deadline: DateTime(2026, 11, 10, 9)),
    Task(
      title: 'Done',
      deadline: DateTime(2026, 11, 12, 12),
      status: TaskStatus.done,
    ),
    Task(title: 'Next week', deadline: DateTime(2026, 11, 20)),
  ];
  final events = [
    Event(
      title: 'Lecture',
      startTime: DateTime(2026, 11, 12, 14),
      endTime: DateTime(2026, 11, 12, 16),
      locationName: 'Hall A',
      considerTravel: true,
    ),
  ];

  List<Notice> build() => buildNotices(
    now: now,
    tasks: tasks,
    events: events,
    travelMinFor: (_) => 20,
  );

  test('builds deadline, travel and event notices in order', () {
    final notices = build();
    expect(notices.map((n) => n.title), [
      'Time to leave',
      'Lecture',
      'Report due',
      'Slides due',
      'Late is overdue',
    ]);
    final leave = notices.first;
    expect(leave.time, DateTime(2026, 11, 12, 13, 30));
    expect(leave.body, contains('Leave by 1:30 PM'));
    expect(notices[1].body, 'Starts in 4h · Hall A');
  });

  test('groups by day', () {
    final notices = build();
    expect(groupOf(notices.first.time, now), NoticeGroup.today);
    expect(groupOf(notices[3].time, now), NoticeGroup.tomorrow);
    expect(groupOf(notices.last.time, now), NoticeGroup.earlier);
  });

  test('soon means within the next 3 hours', () {
    final notices = build();
    expect(notices.first.isSoon(DateTime(2026, 11, 12, 11)), isTrue); // 13:30
    expect(notices[2].isSoon(now), isFalse); // 23:59
  });
}
