import 'dart:async';

import 'package:lifeflow/core/theme/app_theme.dart';

/// Runs before every test file.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Tests run offline, so use the default font instead of downloading Outfit.
  AppTheme.useGoogleFonts = false;
  await testMain();
}
