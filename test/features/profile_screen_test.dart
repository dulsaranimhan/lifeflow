import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/profile.dart';
import 'package:lifeflow/core/theme/app_theme.dart';
import 'package:lifeflow/features/auth/data/auth_providers.dart';
import 'package:lifeflow/features/settings/data/profile_providers.dart';
import 'package:lifeflow/features/settings/presentation/profile_screen.dart';

void main() {
  testWidgets('profile shows the name and current settings', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => null),
          profileProvider.overrideWith(
            (ref) async => const Profile(
              id: 'u1',
              name: 'Dulsara Nimhan',
              travelBufferMin: 15,
              reminderLeadMin: 30,
            ),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Dulsara Nimhan'), findsOneWidget);
    expect(find.text('DN'), findsOneWidget);
    expect(find.text('Remind me 30 min before tasks'), findsOneWidget);
    expect(find.text('15 min buffer before events'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Log out'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Log out'), findsOneWidget);
  });
}
