import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/task.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/form_section.dart';
import '../../../core/widgets/square_back_button.dart';
import '../../auth/presentation/auth_form_helpers.dart';
import '../data/task_providers.dart';
import 'widgets/task_style.dart';

/// 05 – Add Task. Also used to edit an existing [task].
class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

const durationOptions = [15, 30, 45, 60, 90, 120, 180, 240];

String durationLabel(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes / 60;
  final text = h == h.roundToDouble() ? h.toInt().toString() : '$h';
  return h == 1 ? '1 hour' : '$text hours';
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late DateTime _deadline;
  late int _duration;
  late TaskPriority _priority;
  late TaskCategory _category;
  bool _saving = false;

  bool get _editing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _notes = TextEditingController(text: t?.notes ?? '');
    final today = DateTime.now();
    _deadline =
        t?.deadline ?? DateTime(today.year, today.month, today.day, 23, 59);
    _duration = t?.durationMin ?? 60;
    _priority = t?.priority ?? TaskPriority.low;
    _category = t?.category ?? TaskCategory.work;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      _deadline = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _deadline.hour,
        _deadline.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
    );
    if (picked == null) return;
    setState(() {
      _deadline = DateTime(
        _deadline.year,
        _deadline.month,
        _deadline.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final notes = _notes.text.trim();
    final base = widget.task ?? const Task(title: '');
    final task = Task(
      id: base.id,
      userId: base.userId,
      title: _title.text.trim(),
      deadline: _deadline,
      priority: _priority,
      durationMin: _duration,
      status: base.status,
      reminderOn: base.reminderOn,
      category: _category,
      notes: notes.isEmpty ? null : notes,
    );
    try {
      await ref.read(taskActionsProvider).save(task);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        showAuthSnackBar(context, "Couldn't save the task. Please try again.");
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durations = {...durationOptions, _duration}.toList()..sort();

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          // Not a lazy ListView: every field must stay built so the form
          // validates fields that are scrolled off-screen.
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SquareBackButton(
                            color: AppColors.iconBox,
                            icon: Icons.arrow_back,
                          ),
                          const SizedBox(height: 28),
                          Text(
                            _editing ? 'Edit Task' : 'Add Task',
                            style: theme.textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Break it down, get it done.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.muted,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/add_task_illustration.png',
                      width: 130,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FormSection(
                  icon: Icons.description_outlined,
                  label: 'Task title',
                  child: TextFormField(
                    key: const Key('task_title'),
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Finish design slides',
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter a task title'
                        : null,
                  ),
                ),
                FormSection(
                  icon: Icons.calendar_today_outlined,
                  label: 'Due date',
                  onTap: _pickDate,
                  trailing: const Icon(Icons.keyboard_arrow_down),
                  child: Row(
                    children: [
                      FormValue(DateFormat('EEE, MMM d, y').format(_deadline)),
                      const SizedBox(width: 12),
                      ActionChip(
                        label: Text(DateFormat('h:mm a').format(_deadline)),
                        avatar: const Icon(Icons.schedule, size: 18),
                        onPressed: _pickTime,
                        shape: const StadiumBorder(),
                        side: BorderSide.none,
                        backgroundColor: AppColors.field,
                      ),
                    ],
                  ),
                ),
                FormSection(
                  icon: Icons.schedule,
                  label: 'Estimated duration',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      key: const Key('task_duration'),
                      value: _duration,
                      isExpanded: true,
                      isDense: true,
                      borderRadius: BorderRadius.circular(16),
                      style: theme.textTheme.titleMedium,
                      items: [
                        for (final m in durations)
                          DropdownMenuItem(
                            value: m,
                            child: Text(durationLabel(m)),
                          ),
                      ],
                      onChanged: (v) => setState(() => _duration = v!),
                    ),
                  ),
                ),
                FormSection(
                  icon: Icons.flag_outlined,
                  label: 'Priority',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in TaskPriority.values.reversed)
                        PillChoice(
                          label: p.label,
                          selected: _priority == p,
                          onTap: () => setState(() => _priority = p),
                          leading: CircleAvatar(
                            radius: 6,
                            backgroundColor: p.dot,
                          ),
                        ),
                    ],
                  ),
                ),
                FormSection(
                  icon: Icons.folder_outlined,
                  label: 'Category',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in TaskCategory.values)
                        PillChoice(
                          label: c.label,
                          selected: _category == c,
                          onTap: () => setState(() => _category = c),
                          leading: Icon(c.icon, size: 18, color: AppColors.ink),
                        ),
                    ],
                  ),
                ),
                FormSection(
                  icon: Icons.edit_outlined,
                  label: 'Notes (optional)',
                  child: TextFormField(
                    key: const Key('task_notes'),
                    controller: _notes,
                    maxLines: 3,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Add any extra details, links or steps...',
                      contentPadding: EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  key: const Key('task_save'),
                  onPressed: _saving ? null : _save,
                  child: LoadingLabel(loading: _saving, label: 'Save task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
