import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/theme/app_theme.dart';
import 'package:lifeflow/features/auth/presentation/login_screen.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(theme: AppTheme.light, home: child),
  );
}

void main() {
  testWidgets('login screen renders its fields and buttons', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));

    expect(find.text('LifeFlow'), findsOneWidget);
    expect(find.text('Good to\nsee you again'), findsOneWidget);
    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_password')), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('empty form shows validation errors', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));

    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('password visibility can be toggled', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));

    expect(find.byTooltip('Show password'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Show password'));
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
