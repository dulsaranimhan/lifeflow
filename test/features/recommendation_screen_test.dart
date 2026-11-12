import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/task.dart';
import 'package:lifeflow/core/theme/app_theme.dart';
import 'package:lifeflow/features/home/data/home_providers.dart';
import 'package:lifeflow/features/recommendation/engine/recommendation_engine.dart';
import 'package:lifeflow/features/recommendation/presentation/recommendation_screen.dart';

/// Phone-sized viewport so the layout matches a real device.
void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget _wrap(RecommendationResult result) => ProviderScope(
  overrides: [homeRecommendationProvider.overrideWith((ref) async => result)],
  child: MaterialApp(theme: AppTheme.light, home: const RecommendationScreen()),
);

void main() {
  const report = Task(
    id: 'a',
    title: 'Finish lab report',
    priority: TaskPriority.high,
    durationMin: 90,
  );
  const reading = Task(id: 'b', title: 'Read chapter 5', durationMin: 45);

  testWidgets('shows the task, reason, alternatives and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const RecommendationResult(
          kind: RecommendationKind.doTask,
          task: report,
          reason: 'Due today · High priority',
          freeMinutes: 120,
          alternatives: [reading],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Recommended\nfor you'), findsOneWidget);
    expect(find.text('Finish lab report'), findsOneWidget);
    expect(find.text('Why this helps'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Read chapter 5'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Read chapter 5'), findsOneWidget);
    expect(find.text('Start Now'), findsOneWidget);
    expect(find.text('Postpone'), findsOneWidget);
    expect(find.text('Ignore'), findsOneWidget);
  });

  testWidgets('picking an alternative swaps the suggested task', (
    tester,
  ) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(
      _wrap(
        const RecommendationResult(
          kind: RecommendationKind.doTask,
          task: report,
          reason: 'Due today',
          alternatives: [reading],
        ),
      ),
    );
    await tester.pump();

    final alternative = find.text('Read chapter 5');
    await tester.scrollUntilVisible(
      alternative,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(alternative);
    await tester.pumpAndSettle();
    await tester.tap(alternative);
    await tester.pumpAndSettle();

    // The chosen task is now in the hero card and the original is the
    // alternative.
    expect(find.text('Read chapter 5'), findsOneWidget);
    expect(find.text('Finish lab report'), findsOneWidget);
    expect(find.textContaining('it is the most urgent'), findsNothing);
  });

  testWidgets('all clear only offers "Got it"', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const RecommendationResult(
          kind: RecommendationKind.allClear,
          reason: 'No pending tasks. Enjoy your free time!',
        ),
      ),
    );
    await tester.pump();

    expect(find.text("You're all caught up"), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    expect(find.text('Postpone'), findsNothing);
  });
}
