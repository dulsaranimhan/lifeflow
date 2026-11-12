import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

/// Yellow rounded-square back button used in page headers.
class SquareBackButton extends StatelessWidget {
  const SquareBackButton({
    super.key,
    this.onPressed,
    this.color = AppColors.yellow,
    this.icon = Icons.chevron_left,
  });

  final VoidCallback? onPressed;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed ?? () => context.pop(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.ink),
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
