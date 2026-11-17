class ActivityEntity {
  final String id;
  final String type;
  final String icon;
  final int durationMinutes;
  final int caloriesBurned;
  final double? distanceKm;
  final String notes;
  final DateTime timestamp;

  const ActivityEntity({
    required this.id,
    required this.type,
    required this.icon,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.distanceKm,
    this.notes = '',
    required this.timestamp,
  });

  ActivityEntity copyWith({
    String? id,
    String? type,
    String? icon,
    int? durationMinutes,
    int? caloriesBurned,
    double? distanceKm,
    String? notes,
    DateTime? timestamp,
  }) {
    return ActivityEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      distanceKm: distanceKm ?? this.distanceKm,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
