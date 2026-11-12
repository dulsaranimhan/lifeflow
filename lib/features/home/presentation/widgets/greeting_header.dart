import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';

/// Logo + avatar row, "Good morning, Dulsara ☀️" and today's date.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.name, required this.now});

  final String name;
  final DateTime now;

  static String greetingFor(DateTime time) {
    if (time.hour < 12) return 'Good morning';
    if (time.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String emojiFor(DateTime time) {
    if (time.hour < 12) return '☀️';
    if (time.hour < 17) return '🌤️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = name.trim().split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppTopBar(),
        const SizedBox(height: 32),
        Text(
          firstName.isEmpty
              ? '${greetingFor(now)} ${emojiFor(now)}'
              : '${greetingFor(now)},\n$firstName ${emojiFor(now)}',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE, MMMM d').format(now),
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
