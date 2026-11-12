import 'package:flutter/material.dart';

import 'app_colors.dart';

export 'app_colors.dart';

/// Material 3 theme used across the app.
abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.yellow,
      primary: AppColors.yellow,
      onPrimary: AppColors.ink,
      secondary: AppColors.amber,
      onSecondary: AppColors.ink,
      surface: AppColors.background,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.muted,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dividerColor: AppColors.divider,
    );
  }
}
