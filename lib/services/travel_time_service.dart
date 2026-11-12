import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estimates how long it takes to travel from the user's current location.
abstract class TravelTimeService {
  /// Travel time in whole minutes to the given coordinates.
  Future<int> minutesTo(double lat, double lng);
}

/// Placeholder that always returns a fixed travel time.
///
/// Hirushi will replace this with a real implementation (current location +
/// Google Maps Routes API) in the events/services work.
class FakeTravelTimeService implements TravelTimeService {
  const FakeTravelTimeService({this.minutes = 20});

  final int minutes;

  @override
  Future<int> minutesTo(double lat, double lng) async => minutes;
}

final travelTimeServiceProvider = Provider<TravelTimeService>((ref) {
  return const FakeTravelTimeService();
});
