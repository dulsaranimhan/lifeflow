import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/core/models/event.dart';
import 'package:lifeflow/core/models/profile.dart';
import 'package:lifeflow/core/models/task.dart';
import 'package:lifeflow/features/home/data/home_data.dart';
import 'package:lifeflow/features/home/presentation/widgets/greeting_header.dart';

void main() {
  final now = DateTime(2026, 11, 12, 10, 0);

  Event event(String title, int hour) => Event(
    title: title,
    startTime: DateTime(2026, 11, 12, hour),
    endTime: DateTime(2026, 11, 12, hour + 1),
  );

  final data = HomeData(
    profile: const Profile(id: 'u1', name: 'Dulsara', travelBufferMin: 15),
    pendingTasks: [
      Task(title: 'Later', deadline: DateTime(2026, 11, 20)),
      Task(title: 'Today', deadline: DateTime(2026, 11, 12, 23, 59)),
      const Task(title: 'No deadline'),
    ],
    eventsToday: [event('Past', 8), event('Next', 11), event('Evening', 18)],
  );

  test('nextEvent is the first event that has not started', () {
    expect(data.nextEvent(now)!.title, 'Next');
    expect(data.nextEvent(DateTime(2026, 11, 12, 19)), isNull);
  });

  test('stats and upcoming deadlines', () {
    expect(data.dueTodayCount(now), 1);
    expect(data.upcomingDeadlines().map((t) => t.title), ['Today', 'Later']);
    expect(data.bufferMin, 15);
    expect(data.name, 'Dulsara');
  });

  test('defaults when the profile is missing', () {
    const empty = HomeData(profile: null, pendingTasks: [], eventsToday: []);
    expect(empty.bufferMin, 10);
    expect(empty.name, '');
  });

  test('greeting depends on the time of day', () {
    expect(GreetingHeader.greetingFor(DateTime(2026, 1, 1, 8)), 'Good morning');
    expect(
      GreetingHeader.greetingFor(DateTime(2026, 1, 1, 13)),
      'Good afternoon',
    );
    expect(
      GreetingHeader.greetingFor(DateTime(2026, 1, 1, 20)),
      'Good evening',
    );
  });
}
