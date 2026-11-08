enum RecommendationResponse { start, postpone, done }

/// A "what should I do now?" suggestion (`recommendations` table).
class Recommendation {
  const Recommendation({
    this.id,
    this.userId,
    this.taskId,
    required this.windowStart,
    this.leaveTime,
    required this.reason,
    this.response,
  });

  final String? id;
  final String? userId;

  /// The suggested task, if the recommendation is about a task.
  final String? taskId;

  /// When the free window for this suggestion starts.
  final DateTime windowStart;

  /// When the user should leave to reach the next event on time.
  final DateTime? leaveTime;

  /// Human-readable explanation shown to the user.
  final String reason;

  /// The user's answer, null until they respond.
  final RecommendationResponse? response;

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    final response = map['response'] as String?;
    return Recommendation(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      taskId: map['task_id'] as String?,
      windowStart: DateTime.parse(map['window_start'] as String).toLocal(),
      leaveTime: map['leave_time'] == null
          ? null
          : DateTime.parse(map['leave_time'] as String).toLocal(),
      reason: (map['reason'] as String?) ?? '',
      response:
          response == null ? null : RecommendationResponse.values.byName(response),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'task_id': taskId,
      'window_start': windowStart.toUtc().toIso8601String(),
      'leave_time': leaveTime?.toUtc().toIso8601String(),
      'reason': reason,
      'response': response?.name,
    };
  }
}
