/// A scheduled event such as a lecture or meeting (`events` table).
class Event {
  const Event({
    this.id,
    this.userId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.locationName,
    this.lat,
    this.lng,
    this.considerTravel = false,
    this.reminderMin = 15,
  });

  final String? id;
  final String? userId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? locationName;
  final double? lat;
  final double? lng;

  /// Whether travel time should be planned before this event.
  final bool considerTravel;

  /// Minutes before [startTime] to remind the user.
  final int reminderMin;

  bool get hasLocation => lat != null && lng != null;

  Duration get duration => endTime.difference(startTime);

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      title: map['title'] as String,
      startTime: DateTime.parse(map['start_time'] as String).toLocal(),
      endTime: DateTime.parse(map['end_time'] as String).toLocal(),
      locationName: map['location_name'] as String?,
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      considerTravel: (map['consider_travel'] as bool?) ?? false,
      reminderMin: (map['reminder_min'] as num?)?.toInt() ?? 15,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'title': title,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'location_name': locationName,
      'lat': lat,
      'lng': lng,
      'consider_travel': considerTravel,
      'reminder_min': reminderMin,
    };
  }
}
