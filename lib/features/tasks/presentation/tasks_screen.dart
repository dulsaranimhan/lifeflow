import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/task.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../data/task_providers.dart';
import '../domain/task_list_filter.dart';
import 'widgets/task_tile.dart';

/// 04 – My Tasks (S04).
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _showCompleted = false;
  String _query = '';
  TaskFilter _filter = TaskFilter.all;

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() action, String error) async {
    try {
      await action();
    } catch (_) {
      if (mounted) _snack(error);
    }
  }

  Future<void> _toggle(Task task) => _run(
    () => ref.read(taskActionsProvider).toggleDone(task),
    "Couldn't update the task. Please try again.",
  );

  Future<bool> _confirmDelete(Task task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(tasksProvider);
    final all = tasks.value ?? const <Task>[];
    final pendingCount = all.where((t) => !t.isDone).length;
    final doneCount = all.length - pendingCount;
    final visible = visibleTasks(
      all,
      completed: _showCompleted,
      query: _query,
      filter: _filter,
    );
    final now = DateTime.now();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        heroTag: 'add_task',
        tooltip: 'Add task',
        onPressed: () => context.push(AppRoutes.newTask),
        child: const Icon(Icons.add, size: 36),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(tasksProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
            children: [
              const AppTopBar(),
              const SizedBox(height: 28),
              Text('My Tasks', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text(
                'Small steps. A calmer, happier you.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.muted,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 24),
              _SegmentedTabs(
                left: 'Pending ($pendingCount)',
                right: 'Completed ($doneCount)',
                rightSelected: _showCompleted,
                onChanged: (v) => setState(() => _showCompleted = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('task_search'),
                      onChanged: (v) => setState(() => _query = v),
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: Icon(Icons.search, color: AppColors.muted),
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _FilterButton(
                    value: _filter,
                    onChanged: (f) => setState(() => _filter = f),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...switch (tasks) {
                AsyncError() when all.isEmpty => [
                  _Message(
                    text: "Couldn't load your tasks. Pull down to try again.",
                  ),
                ],
                AsyncLoading() when all.isEmpty => [
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                _ when visible.isEmpty => [
                  _Message(
                    text: _query.isNotEmpty || _filter != TaskFilter.all
                        ? 'No tasks match your search.'
                        : _showCompleted
                        ? 'No completed tasks yet.'
                        : 'No pending tasks. Tap + to add one.',
                  ),
                ],
                _ => [
                  for (final task in visible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(task.id),
                        direction: DismissDirection.endToStart,
                        background: const _DeleteBackground(),
                        confirmDismiss: (_) => _confirmDelete(task),
                        onDismissed: (_) => _run(
                          () => ref.read(taskActionsProvider).delete(task),
                          "Couldn't delete the task.",
                        ),
                        child: TaskTile(
                          task: task,
                          now: now,
                          onToggle: () => _toggle(task),
                          onTap: () =>
                              context.push(AppRoutes.editTask, extra: task),
                        ),
                      ),
                    ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.left,
    required this.right,
    required this.rightSelected,
    required this.onChanged,
  });

  final String left;
  final String right;
  final bool rightSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String text, bool selected, bool value) => Expanded(
      child: Material(
        color: selected ? AppColors.yellow : Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => onChanged(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
    return Container(
      decoration: const ShapeDecoration(
        color: AppColors.field,
        shape: StadiumBorder(),
      ),
      child: Row(
        children: [
          tab(left, !rightSelected, false),
          tab(right, rightSelected, true),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.value, required this.onChanged});

  final TaskFilter value;
  final ValueChanged<TaskFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaskFilter>(
      tooltip: 'Filter tasks',
      initialValue: value,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        for (final f in TaskFilter.options)
          PopupMenuItem(value: f, child: Text(f.label)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const ShapeDecoration(
          color: AppColors.field,
          shape: StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune, size: 20),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 90),
              child: Text(
                value.label.replaceAll(' priority', ''),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: AppColors.highBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.delete_outline, color: AppColors.highText),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: AppColors.muted),
      ),
    );
  }
}
