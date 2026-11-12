import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/event.dart';
import 'package:lifeflow/core/theme/app_theme.dart';
import 'package:lifeflow/features/events/presentation/event_form_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(theme: AppTheme.light, home: child),
);

Future<void> _tapSave(WidgetTester tester) async {
  final save = find.byKey(const Key('event_save'));
  await tester.scrollUntilVisible(
    save,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(save);
  await tester.pump();
}

void main() {
  testWidgets('title is required', (tester) async {
    await tester.pumpWidget(_wrap(const EventFormScreen()));
    await _tapSave(tester);
    expect(find.text('Please enter an event title'), findsOneWidget);
  });

  testWidgets('end time must be after start time', (tester) async {
    final event = Event(
      id: 'e1',
      title: 'Lecture',
      startTime: DateTime(2026, 11, 12, 10),
      endTime: DateTime(2026, 11, 12, 9),
    );
    await tester.pumpWidget(_wrap(EventFormScreen(event: event)));
    expect(find.text('Edit Event'), findsOneWidget);
    await _tapSave(tester);
    expect(find.text('End time must be after start'), findsOneWidget);
  });

  testWidgets('travel switch appears once a location is entered', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const EventFormScreen()));
    expect(find.text('Plan travel time'), findsNothing);
    await tester.enterText(find.byKey(const Key('event_location')), 'Library');
    await tester.pump();
    expect(find.text('Plan travel time'), findsOneWidget);
  });
}
