import 'dart:convert';
import '../../domain/entities/activity_entity.dart';

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    required super.type,
    required super.icon,
    required super.durationMinutes,
    required super.caloriesBurned,
    super.distanceKm,
    super.notes = '',
    required super.timestamp,
  });

  factory ActivityModel.fromEntity(ActivityEntity entity) {
    return ActivityModel(
      id: entity.id,
      type: entity.type,
      icon: entity.icon,
      durationMinutes: entity.durationMinutes,
      caloriesBurned: entity.caloriesBurned,
      distanceKm: entity.distanceKm,
      notes: entity.notes,
      timestamp: entity.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'icon': icon,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'distanceKm': distanceKm,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: map['type'] as String? ?? 'Workout',
      icon: map['icon'] as String? ?? '🏃',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toInt() ?? 0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
      notes: map['notes'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ActivityModel.fromJson(String source) =>
      ActivityModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
