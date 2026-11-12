import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/event.dart';
import 'package:lifeflow/core/models/task.dart';

void main() {
  test('Task round-trips through a Supabase row', () {
    final task = Task(
      title: 'Lab report',
      deadline: DateTime.utc(2026, 11, 12, 18).toLocal(),
      priority: TaskPriority.high,
      durationMin: 90,
      category: TaskCategory.learning,
      notes: 'Section 3',
    );
    final map = task.toMap();
    expect(map.containsKey('id'), isFalse);
    expect(map['category'], 'learning');
    expect(map['priority'], 'high');

    final back = Task.fromMap({...map, 'id': 't1', 'user_id': 'u1'});
    expect(back.id, 't1');
    expect(back.category, TaskCategory.learning);
    expect(back.notes, 'Section 3');
    expect(back.deadline, task.deadline);
  });

  test('Task defaults category to personal for old rows', () {
    final task = Task.fromMap({'id': 't', 'title': 'Old row'});
    expect(task.category, TaskCategory.personal);
    expect(task.status, TaskStatus.pending);
  });

  test('Event keeps notes and location', () {
    final event = Event(
      title: 'Lecture',
      startTime: DateTime(2026, 11, 12, 10),
      endTime: DateTime(2026, 11, 12, 12),
      locationName: 'Hall A',
      lat: 5.9,
      lng: 80.5,
      notes: 'Bring laptop',
    );
    final back = Event.fromMap({...event.toMap(), 'id': 'e1'});
    expect(back.notes, 'Bring laptop');
    expect(back.hasLocation, isTrue);
    expect(back.startTime, event.startTime);
    expect(back.copyWith(title: 'Lab').title, 'Lab');
  });
}
