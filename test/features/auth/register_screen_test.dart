import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/theme/app_theme.dart';
import 'package:lifeflow/features/auth/presentation/register_screen.dart';
import 'package:lifeflow/features/auth/presentation/welcome_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(theme: AppTheme.light, home: child),
);

void main() {
  testWidgets('register shows mismatching password error', (tester) async {
    await tester.pumpWidget(_wrap(const RegisterScreen()));

    await tester.enterText(find.byKey(const Key('register_name')), 'Dulsara');
    await tester.enterText(
      find.byKey(const Key('register_email')),
      'dulsara@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register_password')),
      'secret1',
    );
    await tester.enterText(
      find.byKey(const Key('register_confirm')),
      'secret2',
    );

    final button = find.widgetWithText(FilledButton, 'Create account');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('welcome screen shows the call to action', (tester) async {
    await tester.pumpWidget(_wrap(const WelcomeScreen()));

    expect(find.text('LifeFlow'), findsOneWidget);
    expect(find.text('What should I do now?'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
