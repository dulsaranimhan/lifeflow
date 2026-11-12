import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../events/data/event_providers.dart';
import '../../domain/timeline.dart';

/// Sun–Sat day picker; busy days get a dot.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.selected,
    required this.busyDays,
    required this.onSelect,
  });

  final DateTime selected;

  /// Indexes 0 (Sunday) – 6 (Saturday) that have items.
  final Set<int> busyDays;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final start = startOfWeek(selected);
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: _Day(
                date: start.add(Duration(days: i)),
                selected: isSameDay(start.add(Duration(days: i)), selected),
                isToday: isSameDay(start.add(Duration(days: i)), today),
                busy: busyDays.contains(i),
                onTap: () => onSelect(start.add(Duration(days: i))),
              ),
            ),
        ],
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.date,
    required this.selected,
    required this.isToday,
    required this.busy,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool isToday;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      selected: selected,
      button: true,
      label: DateFormat('EEEE d MMMM').format(date),
      child: Material(
        color: selected ? AppColors.yellow : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  DateFormat('EEE').format(date).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected ? AppColors.ink : AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${date.day}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: selected || isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: !busy
                        ? Colors.transparent
                        : isToday && !selected
                        ? AppColors.amber
                        : AppColors.muted.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
