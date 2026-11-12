import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/event.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/square_back_button.dart';
import '../../auth/presentation/auth_form_helpers.dart';
import '../data/event_providers.dart';

const reminderOptions = [5, 10, 15, 30];

/// 07 – Add Event. Also used to edit an existing [event].
class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.event, this.initialDate});

  final Event? event;

  /// Day pre-selected when adding from the Calendar.
  final DateTime? initialDate;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _notes;
  late DateTime _date;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late int _reminder;
  late bool _considerTravel;
  bool _saving = false;
  String? _timeError;

  bool get _editing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _title = TextEditingController(text: e?.title ?? '');
    _location = TextEditingController(text: e?.locationName ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _location.addListener(() => setState(() {}));
    if (e != null) {
      _date = DateTime(e.startTime.year, e.startTime.month, e.startTime.day);
      _start = TimeOfDay.fromDateTime(e.startTime);
      _end = TimeOfDay.fromDateTime(e.endTime);
    } else {
      final now = DateTime.now();
      final day = widget.initialDate ?? now;
      _date = DateTime(day.year, day.month, day.day);
      final nextHour = (now.hour + 1).clamp(0, 22);
      _start = TimeOfDay(hour: nextHour, minute: 0);
      _end = TimeOfDay(hour: nextHour + 1, minute: 0);
    }
    _reminder = e?.reminderMin ?? 10;
    _considerTravel = e?.considerTravel ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  DateTime _at(TimeOfDay t) =>
      DateTime(_date.year, _date.month, _date.day, t.hour, t.minute);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        // Keep the same length when moving the start time.
        final length = _at(_end).difference(_at(_start));
        _start = picked;
        final end = _at(picked).add(length.isNegative ? Duration.zero : length);
        if (end.day == _date.day) _end = TimeOfDay.fromDateTime(end);
      } else {
        _end = picked;
      }
      _timeError = null;
    });
  }

  Future<void> _save() async {
    final validForm = _formKey.currentState!.validate();
    final startTime = _at(_start);
    final endTime = _at(_end);
    final validTimes = endTime.isAfter(startTime);
    setState(
      () => _timeError = validTimes ? null : 'End time must be after start',
    );
    if (_saving || !validForm || !validTimes) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final location = _location.text.trim();
    final notes = _notes.text.trim();
    final base = widget.event;
    final event = Event(
      id: base?.id,
      userId: base?.userId,
      title: _title.text.trim(),
      startTime: startTime,
      endTime: endTime,
      locationName: location.isEmpty ? null : location,
      // Coordinates are kept only if the place name did not change.
      lat: location == base?.locationName ? base?.lat : null,
      lng: location == base?.locationName ? base?.lng : null,
      considerTravel: location.isNotEmpty && _considerTravel,
      reminderMin: _reminder,
      notes: notes.isEmpty ? null : notes,
    );
    try {
      await ref.read(eventActionsProvider).save(event);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        showAuthSnackBar(context, "Couldn't save the event. Please try again.");
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: SquareBackButton(
                    color: AppColors.iconBox,
                    icon: Icons.arrow_back,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text('LifeFlow', style: theme.textTheme.titleMedium),
                    const SizedBox(width: 6),
                    const CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.yellow,
                      child: Icon(Icons.add, size: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _editing ? 'Edit Event' : 'Add Event',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  "Capture what's on your mind\nand keep your day on track.",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                _FieldRow(
                  icon: Icons.description_outlined,
                  label: 'Event title',
                  child: _InlineField(
                    fieldKey: const Key('event_title'),
                    controller: _title,
                    hint: 'e.g. Lecture, Gym, Group meeting',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter an event title'
                        : null,
                  ),
                ),
                _FieldRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Date',
                  onTap: _pickDate,
                  child: _Value(DateFormat('EEE, d MMM y').format(_date)),
                ),
                _FieldRow(
                  icon: Icons.schedule,
                  label: 'Start time',
                  onTap: () => _pickTime(start: true),
                  child: _Value(timeFormat.format(_at(_start))),
                ),
                _FieldRow(
                  icon: Icons.schedule,
                  label: 'End time',
                  onTap: () => _pickTime(start: false),
                  error: _timeError,
                  child: _Value(timeFormat.format(_at(_end))),
                ),
                _FieldRow(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  child: _InlineField(
                    fieldKey: const Key('event_location'),
                    controller: _location,
                    hint: 'e.g. Faculty of Science, Library, Zoom',
                  ),
                ),
                if (_location.text.trim().isNotEmpty)
                  _FieldRow(
                    icon: Icons.directions_walk,
                    label: 'Plan travel time',
                    trailing: Switch(
                      value: _considerTravel,
                      activeTrackColor: AppColors.yellow,
                      onChanged: (v) => setState(() => _considerTravel = v),
                    ),
                    child: const _Value('Tell me when to leave'),
                  ),
                _FieldRow(
                  icon: Icons.notifications_none_rounded,
                  label: 'Reminder',
                  trailing: const SizedBox.shrink(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      key: const Key('event_reminder'),
                      value: reminderOptions.contains(_reminder)
                          ? _reminder
                          : null,
                      isDense: true,
                      isExpanded: true,
                      hint: _Value('$_reminder minutes before'),
                      borderRadius: BorderRadius.circular(16),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                      items: [
                        for (final m in reminderOptions)
                          DropdownMenuItem(
                            value: m,
                            child: Text('$m minutes before'),
                          ),
                      ],
                      onChanged: (v) => setState(() => _reminder = v!),
                    ),
                  ),
                ),
                _FieldRow(
                  icon: Icons.sticky_note_2_outlined,
                  label: 'Notes',
                  child: _InlineField(
                    fieldKey: const Key('event_notes'),
                    controller: _notes,
                    hint: 'Add any extra details...',
                    maxLines: 3,
                    maxLength: 500,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('event_save'),
                  onPressed: _saving ? null : _save,
                  child: LoadingLabel(loading: _saving, label: 'Save Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Grey rounded row with an icon, bold label and value (07_Add_Event).
class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.icon,
    required this.label,
    required this.child,
    this.onTap,
    this.trailing,
    this.error,
  });

  final IconData icon;
  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.ink, size: 26),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      child,
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            error!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                trailing ??
                    (onTap != null
                        ? const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.muted,
                          )
                        : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: AppColors.muted),
    );
  }
}

/// Borderless text field that sits inside a [_FieldRow].
class _InlineField extends StatelessWidget {
  const _InlineField({
    required this.fieldKey,
    required this.controller,
    required this.hint,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      validator: validator,
      minLines: 1,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.sentences,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: false,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );
  }
}
