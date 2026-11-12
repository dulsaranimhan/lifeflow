import '../../../core/models/event.dart';
import '../../../core/models/task.dart';

/// What the engine suggests the user should do right now.
enum RecommendationKind {
  /// Work on [RecommendationResult.task].
  doTask,

  /// The next event is close (or the leave time has passed): get ready to go.
  prepareToLeave,

  /// There is free time but no pending task fits into it.
  takeBreak,

  /// No pending tasks at all.
  allClear,
}

/// Output of the recommendation engine.
class RecommendationResult {
  const RecommendationResult({
    required this.kind,
    required this.reason,
    this.task,
    this.nextEvent,
    this.leaveTime,
    this.freeMinutes,
    this.travelMin = 0,
    this.alternatives = const [],
  });

  final RecommendationKind kind;

  /// Human-readable explanation, e.g.
  /// "Due today 11:59 PM · High priority · 1h 55m free before you leave".
  final String reason;

  /// The suggested task (only for [RecommendationKind.doTask]).
  final Task? task;

  /// The next upcoming event used for the calculation, if any.
  final Event? nextEvent;

  /// When the user has to leave for [nextEvent]; null if there is no event.
  final DateTime? leaveTime;

  /// Minutes from now until [leaveTime]; null when free time is open-ended.
  final int? freeMinutes;

  /// Travel minutes used for [leaveTime].
  final int travelMin;

  /// The next best tasks after [task] (at most 3).
  final List<Task> alternatives;
}
