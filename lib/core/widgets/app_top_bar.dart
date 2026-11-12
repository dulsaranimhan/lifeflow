import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_providers.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import 'app_logo.dart';

/// Logo on the left, the user's avatar (opens Profile) on the right.
class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLogo(circle: true, icon: Icons.spa_outlined),
        const Spacer(),
        Material(
          color: AppColors.iconBox,
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ),
        const SizedBox(width: 10),
        const UserAvatarButton(),
      ],
    );
  }
}

/// Round avatar with the user's initials.
class UserAvatarButton extends ConsumerWidget {
  const UserAvatarButton({super.key, this.radius = 26});

  final double radius;

  static String initialsOf(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final initials = initialsOf((user?.userMetadata?['name'] as String?) ?? '');
    return Semantics(
      button: true,
      label: 'Profile',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.push(AppRoutes.profile),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.iconBox,
          foregroundColor: AppColors.ink,
          child: initials.isEmpty
              ? const Icon(Icons.person_outline)
              : Text(
                  initials,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }
}
