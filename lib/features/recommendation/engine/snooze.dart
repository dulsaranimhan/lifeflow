import '../../../core/models/task.dart';

/// Removes tasks the user postponed until a time that is still in the future.
List<Task> withoutSnoozed(
  List<Task> tasks,
  Map<String, DateTime> snoozedUntil,
  DateTime now,
) {
  if (snoozedUntil.isEmpty) return tasks;
  return tasks.where((task) {
    final until = task.id == null ? null : snoozedUntil[task.id];
    return until == null || !until.isAfter(now);
  }).toList();
}
