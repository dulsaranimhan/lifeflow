import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/soft_card.dart';

/// Insights tab – outside the current project scope, kept as a placeholder.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Text('Insights', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 24),
            SoftCard(
              child: Column(
                children: [
                  const IconBox(
                    color: AppColors.yellowTint,
                    child: Text('📊', style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(height: 16),
                  Text('Coming soon', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'See how you spend your time and how often you follow '
                    'your recommendations.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
