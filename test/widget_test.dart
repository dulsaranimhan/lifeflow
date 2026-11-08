import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/theme/app_theme.dart';

void main() {
  test('app theme uses brand colours', () {
    final theme = AppTheme.light;
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.navy);
    expect(theme.colorScheme.secondary, AppColors.teal);
    expect(theme.colorScheme.brightness, Brightness.light);
  });
}
