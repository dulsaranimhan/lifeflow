import '../../../core/models/event.dart';

/// Minutes before the leave time at which the user is told to get ready.
const int prepareToLeaveThresholdMin = 10;

/// leaveTime = event start − travel − buffer.
///
/// Travel only counts when the event has a location and asks for travel to be
/// considered; otherwise [travelMin] is ignored.
DateTime leaveTimeFor(
  Event event, {
  required int travelMin,
  required int bufferMin,
}) {
  final travel = effectiveTravelMin(event, travelMin);
  return event.startTime.subtract(Duration(minutes: travel + bufferMin));
}

/// The travel minutes that actually apply to [event].
int effectiveTravelMin(Event event, int travelMin) {
  if (!event.considerTravel || !event.hasLocation) return 0;
  return travelMin < 0 ? 0 : travelMin;
}

/// Whole minutes from [now] until [leaveTime] (negative if already passed).
int freeMinutesUntil(DateTime now, DateTime leaveTime) {
  return leaveTime.difference(now).inMinutes;
}
