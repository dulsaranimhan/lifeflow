import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'soft_card.dart';

/// White card with a yellow-tinted round icon, a small label and a field
/// (Add Task / Add Event forms).
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.icon,
    required this.label,
    required this.child,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.yellowTint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.amber, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  child,
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 8),
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }
}

/// Pill-shaped choice chip: yellow when selected, grey otherwise.
class PillChoice extends StatelessWidget {
  const PillChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.yellow : AppColors.field,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 6)],
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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

/// Read-only value text for picker rows ("Mon, Apr 22, 2024").
class FormValue extends StatelessWidget {
  const FormValue(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}
