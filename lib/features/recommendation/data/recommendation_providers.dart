import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/recommendation.dart';
import '../../../core/models/task.dart';
import '../../home/data/home_providers.dart';
import '../engine/recommendation_result.dart';
import 'recommendation_repository.dart';

final recommendationRepositoryProvider = Provider<RecommendationRepository>((
  ref,
) {
  return RecommendationRepository(Supabase.instance.client);
});

/// Task id → time until which it should not be recommended again.
final snoozedTasksProvider =
    NotifierProvider<SnoozedTasks, Map<String, DateTime>>(SnoozedTasks.new);

class SnoozedTasks extends Notifier<Map<String, DateTime>> {
  @override
  Map<String, DateTime> build() => const {};

  void snooze(Task task, Duration duration) {
    final id = task.id;
    if (id == null) return;
    state = {...state, id: DateTime.now().add(duration)};
  }
}

const postponeFor = Duration(minutes: 30);
const ignoreFor = Duration(hours: 2);

/// Records the user's answer and updates Home.
final recommendationActionsProvider = Provider<RecommendationActions>(
  RecommendationActions.new,
);

class RecommendationActions {
  RecommendationActions(this._ref);

  final Ref _ref;

  Future<void> start(RecommendationResult result, Task task) =>
      _record(result, task, RecommendationResponse.start);

  Future<void> postpone(RecommendationResult result, Task task) async {
    _ref.read(snoozedTasksProvider.notifier).snooze(task, postponeFor);
    await _record(result, task, RecommendationResponse.postpone);
  }

  /// "Ignore" is stored as a postpone, but hides the task for longer.
  Future<void> ignore(RecommendationResult result, Task task) async {
    _ref.read(snoozedTasksProvider.notifier).snooze(task, ignoreFor);
    await _record(result, task, RecommendationResponse.postpone);
  }

  Future<void> _record(
    RecommendationResult result,
    Task task,
    RecommendationResponse response,
  ) async {
    final now = _ref.read(homeClockProvider);
    await _ref
        .read(recommendationRepositoryProvider)
        .save(
          Recommendation(
            taskId: task.id,
            windowStart: now,
            leaveTime: result.leaveTime,
            reason: result.reason,
            response: response,
          ),
        );
    _ref.read(homeClockProvider.notifier).tick();
  }
}
