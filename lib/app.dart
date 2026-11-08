import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

/// Root widget of LifeFlow.
class LifeFlowApp extends StatelessWidget {
  const LifeFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(
        body: Center(child: Text('What should I do now?')),
      ),
    );
  }
}

/// Shown when SUPABASE_URL / SUPABASE_ANON_KEY are missing from `.env`.
class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Supabase is not configured.\n\n'
              'Copy .env.example to .env and fill in SUPABASE_URL and '
              'SUPABASE_ANON_KEY, then restart the app.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
