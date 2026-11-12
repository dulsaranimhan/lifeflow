import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/square_back_button.dart';
import '../../auth/data/auth_providers.dart';

/// 10 – Profile and settings (S08).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      // The router redirects to the Welcome screen once signed out.
    } catch (_) {
      if (context.mounted) {
        _snack(context, 'Could not log out. Please try again.');
      }
    }
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final name = (user?.userMetadata?['name'] as String?)?.trim() ?? '';

    void soon(String what) => _snack(context, '$what is coming soon');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            const PageHeader(title: 'Profile'),
            const SizedBox(height: 28),
            Center(child: _ProfileAvatar(name: name)),
            const SizedBox(height: 18),
            Text(
              name.isEmpty ? 'LifeFlow user' : name,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 28),
            _SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Manage reminders and alerts',
              onTap: () => soon('Notification settings'),
            ),
            _SettingsTile(
              icon: Icons.schedule_rounded,
              title: 'Working hours',
              subtitle: 'Set your availability',
              onTap: () => soon('Working hours'),
            ),
            _SettingsTile(
              icon: Icons.directions_walk_rounded,
              title: 'Travel preferences',
              subtitle: 'Buffer time before events',
              onTap: () => soon('Travel preferences'),
            ),
            _SettingsTile(
              icon: Icons.eco_outlined,
              title: 'Energy & focus',
              subtitle: 'Personalize your work style',
              onTap: () => soon('Energy & focus'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _signOut(context, ref),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: AppColors.iconBox,
            foregroundColor: AppColors.ink,
            child: initials.isEmpty
                ? const Icon(Icons.person_outline, size: 56)
                : Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.yellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            IconBox(
              size: 60,
              color: AppColors.yellowTint,
              child: Icon(icon, size: 28, color: AppColors.ink),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}
