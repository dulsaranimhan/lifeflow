import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

export 'app_colors.dart';

/// Material 3 theme used across the app.
abstract final class AppTheme {
  /// Set to false in tests so the font is not downloaded.
  static bool useGoogleFonts = true;

  static TextTheme _textTheme(TextTheme base) {
    final themed = base
        .copyWith(
          headlineLarge: base.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);
    // Outfit is the closest Google Font to the geometric font in the design.
    return useGoogleFonts ? GoogleFonts.outfitTextTheme(themed) : themed;
  }

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

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: _textTheme(base.textTheme),
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
