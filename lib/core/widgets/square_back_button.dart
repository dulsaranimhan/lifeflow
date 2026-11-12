import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

/// Yellow rounded-square back button used in page headers.
class SquareBackButton extends StatelessWidget {
  const SquareBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.yellow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed ?? () => context.pop(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.chevron_left, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// Header row: back button + bold page title.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SquareBackButton(),
        const SizedBox(width: 16),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?trailing,
      ],
    );
  }
}
