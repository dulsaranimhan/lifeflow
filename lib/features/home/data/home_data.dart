import '../../../core/models/event.dart';
import '../../../core/models/profile.dart';
import '../../../core/models/task.dart';

/// Everything the Home screen needs, loaded in one go.
class HomeData {
  const HomeData({
    required this.profile,
    required this.pendingTasks,
    required this.eventsToday,
  });

  /// May be null if the profile row has not been created yet.
  final Profile? profile;
  final List<Task> pendingTasks;

  /// Today's events ordered by start time.
  final List<Event> eventsToday;

  String get name => profile?.name ?? '';

  int get bufferMin => profile?.travelBufferMin ?? 10;

  int get reminderLeadMin => profile?.reminderLeadMin ?? 15;

  /// The first event today that has not started yet.
  Event? nextEvent(DateTime now) {
    for (final event in eventsToday) {
      if (event.startTime.isAfter(now)) return event;
    }
    return null;
  }

  int dueTodayCount(DateTime now) {
    return pendingTasks.where((task) {
      final d = task.deadline;
      return d != null &&
          d.year == now.year &&
          d.month == now.month &&
          d.day == now.day;
    }).length;
  }

  /// Pending tasks with a deadline, soonest first.
  List<Task> upcomingDeadlines({int limit = 5}) {
    final withDeadline = pendingTasks.where((t) => t.deadline != null).toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
    return withDeadline.take(limit).toList();
  }
}
