import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/reminder_service.dart';
import '../../auth/data/auth_providers.dart';
import '../../events/data/event_providers.dart';
import '../../home/data/home_providers.dart';
import '../../tasks/data/task_providers.dart';
import '../domain/reminder_plan.dart';
import 'notice_providers.dart';

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => ReminderService.instance,
);

/// Keeps phone reminders in step with tasks, events and profile settings.
/// Watched by the app shell; re-runs whenever any of them change.
final reminderSyncProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(reminderServiceProvider);
  if (ref.watch(currentUserProvider) == null) {
    await service.clear();
    return 0;
  }
  final tasks = await ref.watch(tasksProvider.future);
  final events = await ref.watch(upcomingEventsProvider.future);
  final travel = await ref.watch(upcomingTravelProvider.future);
  final data = await ref.watch(homeDataProvider.future);

  final plan = planReminders(
    now: DateTime.now(),
    tasks: tasks,
    events: events,
    travelMinFor: (event) => travel[event] ?? 0,
    bufferMin: data.bufferMin,
    leadMin: data.reminderLeadMin,
  );
  await service.sync(plan);
  return plan.length;
});
