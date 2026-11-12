import 'package:intl/intl.dart';

import '../../../core/models/event.dart';
import '../../../core/models/task.dart';

const _separator = ' · ';

/// "1h 55m", "45m", "2h".
String formatMinutes(int minutes) {
  if (minutes <= 0) return '0m';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

/// "11:59 PM".
String formatClock(DateTime time) => DateFormat('h:mm a').format(time);

/// "Due today 11:59 PM", "Due tomorrow 9:00 AM", "Due Fri 3:00 PM",
/// "Due 24 Nov", "Overdue since 8:00 AM" or "No deadline".
String describeDeadline(DateTime? deadline, DateTime now) {
  if (deadline == null) return 'No deadline';
  if (deadline.isBefore(now)) {
    return _isSameDay(deadline, now)
        ? 'Overdue since ${formatClock(deadline)}'
        : 'Overdue since ${DateFormat('d MMM').format(deadline)}';
  }
  final days = _dateOnly(deadline).difference(_dateOnly(now)).inDays;
  if (days == 0) return 'Due today ${formatClock(deadline)}';
  if (days == 1) return 'Due tomorrow ${formatClock(deadline)}';
  if (days < 7) {
    return 'Due ${DateFormat('EEE').format(deadline)} ${formatClock(deadline)}';
  }
  return 'Due ${DateFormat('d MMM').format(deadline)}';
}

String describePriority(TaskPriority priority) => switch (priority) {
  TaskPriority.high => 'High priority',
  TaskPriority.medium => 'Medium priority',
  TaskPriority.low => 'Low priority',
};

/// Reason shown for a suggested task.
String doTaskReason(Task task, DateTime now, int? freeMinutes) {
  final free = freeMinutes == null
      ? 'No more events today'
      : '${formatMinutes(freeMinutes)} free before you leave';
  return [
    describeDeadline(task.deadline, now),
    describePriority(task.priority),
    free,
  ].join(_separator);
}

/// Reason shown when the user should get ready to leave.
String prepareToLeaveReason(
  Event event,
  DateTime now,
  DateTime leaveTime,
  int travelMin,
) {
  final leave = leaveTime.isAfter(now)
      ? 'Leave by ${formatClock(leaveTime)}'
      : 'You should have left at ${formatClock(leaveTime)}';
  final parts = [
    leave,
    '${event.title} starts at ${formatClock(event.startTime)}',
    if (travelMin > 0) '$travelMin min travel',
  ];
  return parts.join(_separator);
}

/// Reason shown when nothing fits into the free time.
String takeBreakReason(int freeMinutes) {
  return 'Only ${formatMinutes(freeMinutes)} free before you leave'
      '$_separator'
      'No pending task fits — take a short break';
}

/// Reason shown when there are no pending tasks.
const allClearReason = 'No pending tasks. Enjoy your free time!';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
