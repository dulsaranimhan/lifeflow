/// A user's profile row (`profiles` table).
class Profile {
  const Profile({
    required this.id,
    required this.name,
    this.travelBufferMin = 10,
    this.reminderLeadMin = 15,
  });

  final String id;
  final String name;

  /// Extra minutes added to travel time before events.
  final int travelBufferMin;

  /// Minutes before a task/event that a reminder fires.
  final int reminderLeadMin;

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '',
      travelBufferMin: (map['travel_buffer_min'] as num?)?.toInt() ?? 10,
      reminderLeadMin: (map['reminder_lead_min'] as num?)?.toInt() ?? 15,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'travel_buffer_min': travelBufferMin,
      'reminder_lead_min': reminderLeadMin,
    };
  }

  Profile copyWith({String? name, int? travelBufferMin, int? reminderLeadMin}) {
    return Profile(
      id: id,
      name: name ?? this.name,
      travelBufferMin: travelBufferMin ?? this.travelBufferMin,
      reminderLeadMin: reminderLeadMin ?? this.reminderLeadMin,
    );
  }
}
