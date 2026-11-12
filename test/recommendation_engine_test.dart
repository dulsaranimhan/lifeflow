// T04 – "What should I do now?" recommendation engine.
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/event.dart';
import 'package:lifeflow/core/models/task.dart';
import 'package:lifeflow/features/recommendation/engine/recommendation_engine.dart';

final now = DateTime(2026, 11, 12, 9, 0);

Task task(
  String title, {
  DateTime? deadline,
  TaskPriority priority = TaskPriority.medium,
  int durationMin = 30,
  TaskStatus status = TaskStatus.pending,
}) {
  return Task(
    id: title,
    title: title,
    deadline: deadline,
    priority: priority,
    durationMin: durationMin,
    status: status,
  );
}

Event event({
  required DateTime start,
  bool considerTravel = true,
  bool withLocation = true,
}) {
  return Event(
    id: 'e1',
    title: 'Lecture',
    startTime: start,
    endTime: start.add(const Duration(hours: 2)),
    lat: withLocation ? 6.0 : null,
    lng: withLocation ? 80.0 : null,
    considerTravel: considerTravel,
  );
}

void main() {
  group('doTask', () {
    test('picks the earliest deadline', () {
      final result = recommend(
        now: now,
        tasks: [
          task('Later', deadline: now.add(const Duration(days: 2))),
          task('Sooner', deadline: now.add(const Duration(hours: 5))),
          task('No deadline'),
        ],
      );

      expect(result.kind, RecommendationKind.doTask);
      expect(result.task!.title, 'Sooner');
      expect(result.alternatives.map((t) => t.title), ['Later', 'No deadline']);
    });

    test('breaks deadline ties by priority, then by shorter duration', () {
      final deadline = now.add(const Duration(hours: 8));
      final result = recommend(
        now: now,
        tasks: [
          task('Low', deadline: deadline, priority: TaskPriority.low),
          task(
            'High long',
            deadline: deadline,
            priority: TaskPriority.high,
            durationMin: 90,
          ),
          task(
            'High short',
            deadline: deadline,
            priority: TaskPriority.high,
            durationMin: 20,
          ),
        ],
      );

      expect(result.task!.title, 'High short');
      expect(result.alternatives.map((t) => t.title), ['High long', 'Low']);
    });

    test('skips tasks that do not fit before the leave time', () {
      // Event at 11:00, 20 min travel, 10 min buffer → leave 10:30 → 90 min.
      final result = recommend(
        now: now,
        tasks: [
          task('Too long', deadline: now, durationMin: 120),
          task('Fits', deadline: now.add(const Duration(days: 1))),
        ],
        nextEvent: event(start: DateTime(2026, 11, 12, 11, 0)),
        travelMin: 20,
        bufferMin: 10,
      );

      expect(result.kind, RecommendationKind.doTask);
      expect(result.task!.title, 'Fits');
      expect(result.leaveTime, DateTime(2026, 11, 12, 10, 30));
      expect(result.freeMinutes, 90);
      expect(result.travelMin, 20);
    });

    test('ignores done tasks', () {
      final result = recommend(
        now: now,
        tasks: [
          task('Done', deadline: now, status: TaskStatus.done),
          task('Pending'),
        ],
      );
      expect(result.task!.title, 'Pending');
    });

    test('keeps at most 3 alternatives', () {
      final result = recommend(
        now: now,
        tasks: [for (var i = 0; i < 6; i++) task('T$i', durationMin: 10 + i)],
      );
      expect(result.task!.title, 'T0');
      expect(result.alternatives, hasLength(3));
    });

    test('reason mentions deadline, priority and free time', () {
      final result = recommend(
        now: now,
        tasks: [
          task(
            'Report',
            deadline: DateTime(2026, 11, 12, 23, 59),
            priority: TaskPriority.high,
          ),
        ],
        nextEvent: event(start: DateTime(2026, 11, 12, 11, 25)),
        travelMin: 20,
        bufferMin: 10,
      );
      expect(
        result.reason,
        'Due today 11:59 PM · High priority · 1h 55m free before you leave',
      );
    });

    test('free time is open-ended without a next event', () {
      final result = recommend(
        now: now,
        tasks: [task('Big', durationMin: 600)],
      );
      expect(result.kind, RecommendationKind.doTask);
      expect(result.leaveTime, isNull);
      expect(result.freeMinutes, isNull);
      expect(result.reason, contains('No more events today'));
    });
  });

  group('travel', () {
    test('a place name without coordinates still needs travel', () {
      final result = recommend(
        now: now,
        tasks: [task('A')],
        nextEvent: Event(
          title: 'Lab',
          startTime: DateTime(2026, 11, 12, 11, 0),
          endTime: DateTime(2026, 11, 12, 12, 0),
          locationName: 'Faculty of Science',
          considerTravel: true,
        ),
        travelMin: 20,
        bufferMin: 10,
      );
      expect(result.leaveTime, DateTime(2026, 11, 12, 10, 30));
      expect(result.travelMin, 20);
    });

    test('travel is ignored when the event has no location', () {
      final result = recommend(
        now: now,
        tasks: [task('A')],
        nextEvent: event(
          start: DateTime(2026, 11, 12, 11, 0),
          withLocation: false,
        ),
        travelMin: 20,
        bufferMin: 10,
      );
      expect(result.leaveTime, DateTime(2026, 11, 12, 10, 50));
      expect(result.travelMin, 0);
    });

    test('travel is ignored when considerTravel is off', () {
      final result = recommend(
        now: now,
        tasks: [task('A')],
        nextEvent: event(
          start: DateTime(2026, 11, 12, 11, 0),
          considerTravel: false,
        ),
        travelMin: 20,
      );
      expect(result.leaveTime, DateTime(2026, 11, 12, 10, 50));
    });
  });

  group('prepareToLeave', () {
    test('when the leave time is within 10 minutes', () {
      // Leave at 9:08 → 8 min away.
      final result = recommend(
        now: now,
        tasks: [task('A', durationMin: 5)],
        nextEvent: event(start: DateTime(2026, 11, 12, 9, 38)),
        travelMin: 20,
        bufferMin: 10,
      );
      expect(result.kind, RecommendationKind.prepareToLeave);
      expect(result.task, isNull);
      expect(result.reason, startsWith('Leave by 9:08 AM'));
      expect(result.reason, contains('20 min travel'));
    });

    test('when the leave time has already passed', () {
      final result = recommend(
        now: now,
        tasks: const [],
        nextEvent: event(start: DateTime(2026, 11, 12, 9, 15)),
        travelMin: 20,
        bufferMin: 10,
      );
      expect(result.kind, RecommendationKind.prepareToLeave);
      expect(result.freeMinutes, isNegative);
      expect(result.reason, startsWith('You should have left at 8:45 AM'));
    });
  });

  group('takeBreak and allClear', () {
    test('takeBreak when no pending task fits the free time', () {
      // Leave at 9:30 → 30 free minutes, task needs 45.
      final result = recommend(
        now: now,
        tasks: [task('Long', durationMin: 45)],
        nextEvent: event(start: DateTime(2026, 11, 12, 10, 0)),
        travelMin: 20,
        bufferMin: 10,
      );
      expect(result.kind, RecommendationKind.takeBreak);
      expect(result.freeMinutes, 30);
      expect(result.reason, startsWith('Only 30m free'));
    });

    test('allClear when there are no pending tasks', () {
      final result = recommend(
        now: now,
        tasks: [task('Done', status: TaskStatus.done)],
      );
      expect(result.kind, RecommendationKind.allClear);
      expect(result.task, isNull);
    });
  });
}
