import 'package:flutter/material.dart';

import '../../../../core/models/task.dart';
import '../../../../core/theme/app_colors.dart';

/// Icons, labels and colours for task categories and priorities.
extension TaskCategoryStyle on TaskCategory {
  String get label => switch (this) {
    TaskCategory.work => 'Work',
    TaskCategory.personal => 'Personal',
    TaskCategory.health => 'Health',
    TaskCategory.learning => 'Learning',
  };

  IconData get icon => switch (this) {
    TaskCategory.work => Icons.work_outline,
    TaskCategory.personal => Icons.home_outlined,
    TaskCategory.health => Icons.favorite_border,
    TaskCategory.learning => Icons.menu_book_outlined,
  };
}

extension TaskPriorityStyle on TaskPriority {
  String get label => switch (this) {
    TaskPriority.high => 'High',
    TaskPriority.medium => 'Medium',
    TaskPriority.low => 'Low',
  };

  Color get background => switch (this) {
    TaskPriority.high => AppColors.highBg,
    TaskPriority.medium => AppColors.mediumBg,
    TaskPriority.low => AppColors.lowBg,
  };

  Color get foreground => switch (this) {
    TaskPriority.high => AppColors.highText,
    TaskPriority.medium => AppColors.mediumText,
    TaskPriority.low => AppColors.lowText,
  };

  /// Dot colour used in the priority selector.
  Color get dot => switch (this) {
    TaskPriority.high => const Color(0xFFF2846B),
    TaskPriority.medium => AppColors.check,
    TaskPriority.low => const Color(0xFF9DB89A),
  };
}

/// Small rounded "High / Medium / Low" chip.
class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: priority.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          color: priority.foreground,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
