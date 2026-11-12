import '../../../core/models/event.dart';
import '../../../core/models/task.dart';
import '../../recommendation/engine/reason_text.dart';
import '../../recommendation/engine/time_window.dart';

/// A phone notification to schedule.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.time,
    required this.title,
    required this.body,
  });

  /// Stable id so the same reminder keeps the same notification slot.
  final int id;
  final DateTime time;
  final String title;
  final String body;
}

/// Stable 31-bit id for a reminder (Dart's String.hashCode is not stable
/// between runs, so a small FNV-1a hash is used instead).
int reminderId(String key) {
  var hash = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

/// Works out which reminders to schedule in the next [horizon]:
/// task deadlines (with [leadMin] warning), event reminders and
/// "time to leave" alerts. At most [limit] of the soonest are returned.
List<PlannedReminder> planReminders({
  required DateTime now,
  required List<Task> tasks,
  required List<Event> events,
  required int Function(Event event) travelMinFor,
  int bufferMin = 10,
  int leadMin = 15,
  Duration horizon = const Duration(days: 7),
  int limit = 60,
}) {
  final end = now.add(horizon);
  final planned = <PlannedReminder>[];
  void add(String key, DateTime time, String title, String body) {
    if (time.isAfter(now) && time.isBefore(end)) {
      planned.add(
        PlannedReminder(
          id: reminderId(key),
          time: time,
          title: title,
          body: body,
        ),
      );
    }
  }

  for (final task in tasks) {
    final deadline = task.deadline;
    if (task.isDone || !task.reminderOn || deadline == null) continue;
    add(
      'task:${task.id ?? task.title}',
      deadline.subtract(Duration(minutes: leadMin)),
      '⏰ ${task.title}',
      'Due at ${formatClock(deadline)} · ${describePriority(task.priority)}',
    );
  }

  for (final event in events) {
    add(
      'event:${event.id ?? event.title}',
      event.startTime.subtract(Duration(minutes: event.reminderMin)),
      '📅 ${event.title}',
      'Starts at ${formatClock(event.startTime)}'
          '${event.locationName == null ? '' : ' · ${event.locationName}'}',
    );
    final travel = effectiveTravelMin(event, travelMinFor(event));
    if (travel > 0) {
      final leave = leaveTimeFor(
        event,
        travelMin: travel,
        bufferMin: bufferMin,
      );
      add(
        'leave:${event.id ?? event.title}',
        leave,
        '🚶 Time to leave',
        'Leave now for ${event.title} – $travel min travel.',
      );
    }
  }

  planned.sort((a, b) => a.time.compareTo(b.time));
  return planned.take(limit).toList();
}
