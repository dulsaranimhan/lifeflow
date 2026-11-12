import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/event.dart';
import 'package:lifeflow/core/models/task.dart';
import 'package:lifeflow/features/schedule/domain/timeline.dart';

void main() {
  final day = DateTime(2026, 11, 12);
  final lecture = Event(
    title: 'Lecture',
    startTime: DateTime(2026, 11, 12, 10),
    endTime: DateTime(2026, 11, 12, 12),
    locationName: 'Faculty',
    considerTravel: true,
  );
  final online = Event(
    title: 'Online call',
    startTime: DateTime(2026, 11, 12, 15),
    endTime: DateTime(2026, 11, 12, 15, 30),
  );
  final otherDay = Event(
    title: 'Tomorrow',
    startTime: DateTime(2026, 11, 13, 9),
    endTime: DateTime(2026, 11, 13, 10),
  );
  final report = Task(
    title: 'Report',
    deadline: DateTime(2026, 11, 12, 23, 59),
    durationMin: 90,
    priority: TaskPriority.high,
  );

  List<TimelineItem> build() => buildTimeline(
    day: day,
    events: [online, otherDay, lecture],
    tasks: [
      report,
      const Task(title: 'No deadline'),
    ],
    travelMinFor: (_) => 20,
  );

  test('orders events, leave rows and tasks by time', () {
    final items = build();
    expect(items.map((i) => i.title), [
      'Leave for Lecture',
      'Lecture',
      'Online call',
      'Report',
    ]);
    expect(items.first.kind, TimelineKind.leave);
    expect(items.first.time, DateTime(2026, 11, 12, 9, 30));
    expect(items[1].subtitle, '2h · Faculty');
    expect(items.last.subtitle, 'Due · 1h 30m · High priority');
  });

  test('no leave row for events without a place', () {
    final items = build();
    expect(
      items.where((i) => i.kind == TimelineKind.leave).single.event,
      lecture,
    );
  });

  test('highlights the first unfinished item', () {
    final items = build();
    expect(highlightIndex(items, DateTime(2026, 11, 12, 11)), 1);
    expect(highlightIndex(items, DateTime(2026, 11, 12, 16)), 3);
    expect(highlightIndex(items, DateTime(2026, 11, 13)), isNull);
  });
}
