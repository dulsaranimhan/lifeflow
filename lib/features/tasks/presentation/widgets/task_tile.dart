import 'package:flutter/material.dart';

import '../../../../core/models/task.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/task_list_filter.dart';
import 'task_style.dart';

/// One row of the Tasks list (04_Tasks).
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.now,
    this.onToggle,
    this.onTap,
  });

  final Task task;
  final DateTime now;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = dueLabel(task.deadline, now);
    final urgent = !task.isDone && (due == 'Today' || due == 'Overdue');

    return Material(
      color: urgent ? const Color(0xFFFEF3D8) : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
          child: Row(
            children: [
              Checkbox(
                value: task.isDone,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                side: const BorderSide(color: AppColors.muted, width: 1.6),
                onChanged: onToggle == null ? null : (_) => onToggle!(),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          task.category.icon,
                          size: 16,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          task.category.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (due.isNotEmpty) ...[
                Text(
                  due,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: urgent ? AppColors.amber : AppColors.muted,
                    fontWeight: urgent ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              PriorityChip(priority: task.priority),
            ],
          ),
        ),
      ),
    );
  }
}
