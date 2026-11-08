enum TaskPriority { high, medium, low }

enum TaskStatus { pending, done }

/// A to-do item (`tasks` table).
class Task {
  const Task({
    this.id,
    this.userId,
    required this.title,
    this.deadline,
    this.priority = TaskPriority.medium,
    this.durationMin = 30,
    this.status = TaskStatus.pending,
    this.reminderOn = true,
  });

  /// Null until the row is inserted.
  final String? id;

  /// Filled by the database (`auth.uid()` default).
  final String? userId;
  final String title;
  final DateTime? deadline;
  final TaskPriority priority;
  final int durationMin;
  final TaskStatus status;
  final bool reminderOn;

  bool get isDone => status == TaskStatus.done;

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      title: map['title'] as String,
      deadline: map['deadline'] == null
          ? null
          : DateTime.parse(map['deadline'] as String).toLocal(),
      priority: TaskPriority.values.byName(
        (map['priority'] as String?) ?? TaskPriority.medium.name,
      ),
      durationMin: (map['duration_min'] as num?)?.toInt() ?? 30,
      status: TaskStatus.values.byName(
        (map['status'] as String?) ?? TaskStatus.pending.name,
      ),
      reminderOn: (map['reminder_on'] as bool?) ?? true,
    );
  }

  /// Omits `id`/`user_id` when null so inserts use database defaults.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'title': title,
      'deadline': deadline?.toUtc().toIso8601String(),
      'priority': priority.name,
      'duration_min': durationMin,
      'status': status.name,
      'reminder_on': reminderOn,
    };
  }

  Task copyWith({
    String? title,
    DateTime? deadline,
    TaskPriority? priority,
    int? durationMin,
    TaskStatus? status,
    bool? reminderOn,
  }) {
    return Task(
      id: id,
      userId: userId,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      durationMin: durationMin ?? this.durationMin,
      status: status ?? this.status,
      reminderOn: reminderOn ?? this.reminderOn,
    );
  }
}
