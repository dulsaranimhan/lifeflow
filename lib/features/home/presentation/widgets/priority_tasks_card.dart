import 'package:flutter/material.dart';

import '../../../../core/models/task.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../recommendation/engine/reason_text.dart';
import '../../../recommendation/engine/task_ranking.dart';

/// "Priority tasks" card: the top pending tasks with a round checkbox.
class PriorityTasksCard extends StatelessWidget {
  const PriorityTasksCard({
    super.key,
    required this.tasks,
    this.onSeeAll,
    this.onToggle,
    this.limit = 3,
  });

  final List<Task> tasks;
  final VoidCallback? onSeeAll;

  /// Called when a checkbox is tapped (null disables the checkboxes).
  final ValueChanged<Task>? onToggle;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = rankTasks(tasks).take(limit).toList();

    return SoftCard(
      key: const Key('priority_tasks_card'),
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Priority tasks',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('See all'), Icon(Icons.chevron_right)],
                ),
              ),
            ],
          ),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No pending tasks 🎉',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ),
          for (var i = 0; i < top.length; i++) ...[
            if (i > 0) const Divider(indent: 48, endIndent: 8),
            _TaskRow(task: top[i], onToggle: onToggle),
          ],
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, this.onToggle});

  final Task task;
  final ValueChanged<Task>? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: task.isDone,
            onChanged: onToggle == null ? null : (_) => onToggle!(task),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              formatMinutes(task.durationMin).replaceAll('m', ' min'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
