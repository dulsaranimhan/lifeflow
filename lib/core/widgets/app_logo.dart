import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Yellow rounded-square mark with a line icon, optionally followed by
/// the "LifeFlow" word mark.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 44,
    this.icon = Icons.eco_outlined,
    this.showName = true,
    this.circle = false,
  });

  final double size;
  final IconData icon;
  final bool showName;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.28),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Icon(icon, color: AppColors.ink, size: size * 0.55),
    );
    if (!showName) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 12),
        Text(
          'LifeFlow',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700, fontSize: size * 0.48),
        ),
      ],
    );
  }
}
