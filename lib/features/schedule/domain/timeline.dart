import '../../../core/models/event.dart';
import '../../../core/models/task.dart';
import '../../recommendation/engine/reason_text.dart';
import '../../recommendation/engine/time_window.dart';

enum TimelineKind { event, task, leave }

/// One row of the day timeline on the Calendar screen.
class TimelineItem {
  const TimelineItem({
    required this.kind,
    required this.time,
    required this.title,
    required this.subtitle,
    this.event,
    this.task,
  });

  final TimelineKind kind;
  final DateTime time;
  final String title;
  final String subtitle;
  final Event? event;
  final Task? task;
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Builds the timeline for [day]: events, a "Leave for …" row before events
/// that need travel, and tasks due that day (at their deadline time).
List<TimelineItem> buildTimeline({
  required DateTime day,
  required List<Event> events,
  required List<Task> tasks,
  required int Function(Event event) travelMinFor,
  int bufferMin = 10,
}) {
  final items = <TimelineItem>[];

  for (final event in events.where((e) => isSameDay(e.startTime, day))) {
    final travel = effectiveTravelMin(event, travelMinFor(event));
    if (travel > 0) {
      items.add(
        TimelineItem(
          kind: TimelineKind.leave,
          time: leaveTimeFor(event, travelMin: travel, bufferMin: bufferMin),
          title: 'Leave for ${event.title}',
          subtitle: '$travel min travel · $bufferMin min buffer',
          event: event,
        ),
      );
    }
    items.add(
      TimelineItem(
        kind: TimelineKind.event,
        time: event.startTime,
        title: event.title,
        subtitle: [
          formatMinutes(event.duration.inMinutes),
          if (event.locationName?.isNotEmpty ?? false) event.locationName!,
        ].join(' · '),
        event: event,
      ),
    );
  }

  for (final task in tasks) {
    final deadline = task.deadline;
    if (deadline == null || !isSameDay(deadline, day)) continue;
    items.add(
      TimelineItem(
        kind: TimelineKind.task,
        time: deadline,
        title: task.title,
        subtitle: [
          task.isDone ? 'Done' : 'Due',
          formatMinutes(task.durationMin),
          '${task.priority.name[0].toUpperCase()}'
              '${task.priority.name.substring(1)} priority',
        ].join(' · '),
        task: task,
      ),
    );
  }

  items.sort((a, b) => a.time.compareTo(b.time));
  return items;
}

/// Index of the row to highlight: the first item that has not finished yet.
int? highlightIndex(List<TimelineItem> items, DateTime now) {
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    final end = item.kind == TimelineKind.event
        ? item.event!.endTime
        : item.time;
    if (end.isAfter(now) && !(item.task?.isDone ?? false)) return i;
  }
  return null;
}
