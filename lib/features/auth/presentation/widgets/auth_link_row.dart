import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// "Already have an account? Log in" style row.
class AuthLinkRow extends StatelessWidget {
  const AuthLinkRow({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.muted),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 36),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}
