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
    expect(find.text('What should I do now?'), findsOneWidget);
    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_password')), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('empty form shows validation errors', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('password visibility can be toggled', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));

    expect(find.byTooltip('Show password'), findsOneWidget);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
