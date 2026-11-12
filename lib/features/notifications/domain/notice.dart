import '../../../core/models/event.dart';
import '../../../core/models/task.dart';
import '../../recommendation/engine/reason_text.dart';
import '../../recommendation/engine/time_window.dart';

enum NoticeType { deadline, travel, event }

enum NoticeGroup { today, tomorrow, earlier }

/// One row of the in-app Notifications list.
class Notice {
  const Notice({
    required this.type,
    required this.time,
    required this.title,
    required this.body,
    this.task,
    this.event,
  });

  final NoticeType type;
  final DateTime time;
  final String title;
  final String body;
  final Task? task;
  final Event? event;

  /// "Unread" dot: things happening in the next 3 hours.
  bool isSoon(DateTime now) =>
      time.isAfter(now) && time.difference(now) <= const Duration(hours: 3);
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

NoticeGroup groupOf(DateTime time, DateTime now) {
  final days = _dateOnly(time).difference(_dateOnly(now)).inDays;
  if (days == 0) return NoticeGroup.today;
  if (days == 1) return NoticeGroup.tomorrow;
  return NoticeGroup.earlier;
}

/// Builds notices for yesterday, today and tomorrow from tasks and events.
List<Notice> buildNotices({
  required DateTime now,
  required List<Task> tasks,
  required List<Event> events,
  required int Function(Event event) travelMinFor,
  int bufferMin = 10,
}) {
  final from = _dateOnly(now).subtract(const Duration(days: 1));
  final to = _dateOnly(now).add(const Duration(days: 2));
  bool inRange(DateTime t) => !t.isBefore(from) && t.isBefore(to);

  final notices = <Notice>[];

  for (final task in tasks) {
    final deadline = task.deadline;
    if (task.isDone || deadline == null) continue;
    final overdue = deadline.isBefore(now);
    if (!inRange(deadline) && !overdue) continue;
    final when = switch (groupOf(deadline, now)) {
      NoticeGroup.today => 'today',
      NoticeGroup.tomorrow => 'tomorrow',
      NoticeGroup.earlier => 'on ${describeDeadline(deadline, now)}',
    };
    notices.add(
      Notice(
        type: NoticeType.deadline,
        time: deadline,
        title: overdue ? '${task.title} is overdue' : '${task.title} due',
        body: overdue
            ? 'This task was due at ${formatClock(deadline)}.'
            : 'Due $when at ${formatClock(deadline)} · '
                  '${describePriority(task.priority)}',
        task: task,
      ),
    );
  }

  for (final event in events.where((e) => inRange(e.startTime))) {
    final travel = effectiveTravelMin(event, travelMinFor(event));
    if (travel > 0) {
      final leave = leaveTimeFor(
        event,
        travelMin: travel,
        bufferMin: bufferMin,
      );
      notices.add(
        Notice(
          type: NoticeType.travel,
          time: leave,
          title: 'Time to leave',
          body:
              'Your ${formatClock(event.startTime)} ${event.title} is '
              '$travel min away. Leave by ${formatClock(leave)}.',
          event: event,
        ),
      );
    }
    final startsIn = event.startTime.difference(now).inMinutes;
    notices.add(
      Notice(
        type: NoticeType.event,
        time: event.startTime,
        title: event.title,
        body: startsIn > 0 && startsIn < 24 * 60
            ? 'Starts in ${formatMinutes(startsIn)}'
                  '${event.locationName == null ? '' : ' · ${event.locationName}'}'
            : 'Reminder ${event.reminderMin} min before'
                  '${event.locationName == null ? '' : ' · ${event.locationName}'}',
        event: event,
      ),
    );
  }

  // Today and tomorrow in time order; earlier items newest first.
  notices.sort((a, b) {
    final ga = groupOf(a.time, now), gb = groupOf(b.time, now);
    if (ga != gb) return ga.index.compareTo(gb.index);
    return ga == NoticeGroup.earlier
        ? b.time.compareTo(a.time)
        : a.time.compareTo(b.time);
  });
  return notices;
}
