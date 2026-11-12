import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/theme/app_theme.dart';

void main() {
  test('app theme uses the design colour tokens', () {
    final theme = AppTheme.light;
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.yellow);
    expect(theme.colorScheme.onPrimary, AppColors.ink);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(theme.colorScheme.brightness, Brightness.light);
  });
}
