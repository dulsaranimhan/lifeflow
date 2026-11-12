import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/features/recommendation/engine/reason_text.dart';

void main() {
  final now = DateTime(2026, 11, 12, 9, 0); // Thursday

  test('formatMinutes', () {
    expect(formatMinutes(45), '45m');
    expect(formatMinutes(120), '2h');
    expect(formatMinutes(115), '1h 55m');
    expect(formatMinutes(-5), '0m');
  });

  test('describeDeadline', () {
    expect(describeDeadline(null, now), 'No deadline');
    expect(
      describeDeadline(DateTime(2026, 11, 12, 23, 59), now),
      'Due today 11:59 PM',
    );
    expect(
      describeDeadline(DateTime(2026, 11, 13, 9, 0), now),
      'Due tomorrow 9:00 AM',
    );
    expect(
      describeDeadline(DateTime(2026, 11, 14, 15, 0), now),
      'Due Sat 3:00 PM',
    );
    expect(describeDeadline(DateTime(2026, 11, 30), now), 'Due 30 Nov');
    expect(
      describeDeadline(DateTime(2026, 11, 12, 8, 0), now),
      'Overdue since 8:00 AM',
    );
  });
}
