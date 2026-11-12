import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/form_section.dart';

/// Bottom sheet to pick a number of minutes from [options].
Future<int?> showMinutesPicker(
  BuildContext context, {
  required String title,
  required String description,
  required List<int> options,
  required int current,
}) {
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) {
      var selected = current;
      final theme = Theme.of(context);
      return StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in options)
                      PillChoice(
                        label: m == 0 ? 'None' : '$m min',
                        selected: selected == m,
                        onTap: () => setState(() => selected = m),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
