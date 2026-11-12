import '../../../core/models/event.dart';
import '../../../core/models/task.dart';
import 'reason_text.dart';
import 'recommendation_result.dart';
import 'task_filter.dart';
import 'task_ranking.dart';
import 'time_window.dart';

export 'recommendation_result.dart';

/// Answers "What should I do now?".
///
/// 1. leaveTime = nextEvent.start − travel − buffer (open-ended if no event).
/// 2. freeMinutes = leaveTime − now.
/// 3. If the leave time is within [prepareToLeaveThresholdMin] minutes (or has
///    passed) → [RecommendationKind.prepareToLeave].
/// 4. No pending tasks → [RecommendationKind.allClear].
/// 5. Keep pending tasks that fit into freeMinutes; none fit →
///    [RecommendationKind.takeBreak].
/// 6. Rank by deadline, priority, duration and suggest the best one.
RecommendationResult recommend({
  required DateTime now,
  required List<Task> tasks,
  Event? nextEvent,
  int travelMin = 0,
  int bufferMin = 10,
}) {
  DateTime? leaveTime;
  int? freeMinutes;
  var travel = 0;

  if (nextEvent != null) {
    travel = effectiveTravelMin(nextEvent, travelMin);
    leaveTime = leaveTimeFor(
      nextEvent,
      travelMin: travelMin,
      bufferMin: bufferMin,
    );
    freeMinutes = freeMinutesUntil(now, leaveTime);

    if (freeMinutes <= prepareToLeaveThresholdMin) {
      return RecommendationResult(
        kind: RecommendationKind.prepareToLeave,
        reason: prepareToLeaveReason(nextEvent, now, leaveTime, travel),
        nextEvent: nextEvent,
        leaveTime: leaveTime,
        freeMinutes: freeMinutes,
        travelMin: travel,
      );
    }
  }

  final pending = tasks.where((t) => t.status == TaskStatus.pending).toList();
  if (pending.isEmpty) {
    return RecommendationResult(
      kind: RecommendationKind.allClear,
      reason: allClearReason,
      nextEvent: nextEvent,
      leaveTime: leaveTime,
      freeMinutes: freeMinutes,
      travelMin: travel,
    );
  }

  final ranked = rankTasks(feasibleTasks(pending, freeMinutes));
  if (ranked.isEmpty) {
    return RecommendationResult(
      kind: RecommendationKind.takeBreak,
      // freeMinutes is non-null here: with open-ended time every task fits.
      reason: takeBreakReason(freeMinutes!),
      nextEvent: nextEvent,
      leaveTime: leaveTime,
      freeMinutes: freeMinutes,
      travelMin: travel,
    );
  }

  final best = ranked.first;
  return RecommendationResult(
    kind: RecommendationKind.doTask,
    task: best,
    reason: doTaskReason(best, now, freeMinutes),
    nextEvent: nextEvent,
    leaveTime: leaveTime,
    freeMinutes: freeMinutes,
    travelMin: travel,
    alternatives: ranked.skip(1).take(3).toList(),
  );
}
