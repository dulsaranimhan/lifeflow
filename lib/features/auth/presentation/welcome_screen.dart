import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import 'widgets/auth_link_row.dart';

/// 01 – Welcome: first screen for signed-out users.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: AppLogo(
                      size: 88,
                      icon: Icons.wb_twilight,
                      showName: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'LifeFlow',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What should I do now?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.muted,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Image.asset(
                    'assets/images/welcome_illustration.png',
                    height: 260,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 28),
                  const _PageDots(),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.register),
                    child: const Text('Get Started'),
                  ),
                  const SizedBox(height: 20),
                  AuthLinkRow(
                    question: 'Already have an account?',
                    action: 'Log in',
                    onTap: () => context.push(AppRoutes.login),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots();

  @override
  Widget build(BuildContext context) {
    Widget dot(bool active) => Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.yellow : AppColors.divider,
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [dot(true), dot(false), dot(false)],
    );
  }
}
