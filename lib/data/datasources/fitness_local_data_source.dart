import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';

abstract class FitnessLocalDataSource {
  Future<List<ActivityModel>> getActivities();
  Future<void> saveActivities(List<ActivityModel> activities);
  Future<int> getSteps();
  Future<void> saveSteps(int steps);
}

class FitnessLocalDataSourceImpl implements FitnessLocalDataSource {
  static const String _activitiesKey = 'pulsefit_activities_v1';
  static const String _stepsKey = 'pulsefit_daily_steps_v1';

  final SharedPreferences sharedPreferences;

  FitnessLocalDataSourceImpl({required this.sharedPreferences});

  static List<ActivityModel> _generateSeedActivities() {
    final now = DateTime.now();
    return [
      ActivityModel(
        id: 'seed_1',
        type: 'Running',
        icon: '🏃',
        durationMinutes: 32,
        caloriesBurned: 340,
        distanceKm: 4.8,
        notes: 'Morning interval sprint around the park',
        timestamp: DateTime(now.year, now.month, now.day, 7, 30),
      ),
      ActivityModel(
        id: 'seed_2',
        type: 'Gym / Strength',
        icon: '🏋️',
        durationMinutes: 45,
        caloriesBurned: 260,
        notes: 'Upper body hypertrophy & core',
        timestamp: DateTime(now.year, now.month, now.day, 12, 15),
      ),
      ActivityModel(
        id: 'seed_3',
        type: 'Cycling',
        icon: '🚴',
        durationMinutes: 25,
        caloriesBurned: 190,
        distanceKm: 8.2,
        notes: 'Sunset tempo ride',
        timestamp: DateTime(now.year, now.month, now.day - 1, 18, 0),
      ),
      ActivityModel(
        id: 'seed_4',
        type: 'Swimming',
        icon: '🏊',
        durationMinutes: 40,
        caloriesBurned: 380,
        notes: 'Freestyle endurance laps',
        timestamp: DateTime(now.year, now.month, now.day - 2, 16, 45),
      ),
    ];
  }

  @override
  Future<List<ActivityModel>> getActivities() async {
    final String? jsonString = sharedPreferences.getString(_activitiesKey);

    if (jsonString == null || jsonString.isEmpty) {
      final seeds = _generateSeedActivities();
      await saveActivities(seeds);
      return seeds;
    }

    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => ActivityModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _generateSeedActivities();
    }
  }

  @override
  Future<void> saveActivities(List<ActivityModel> activities) async {
    final rawList = activities.map((a) => a.toMap()).toList();
    await sharedPreferences.setString(_activitiesKey, json.encode(rawList));
  }

  @override
  Future<int> getSteps() async {
    return sharedPreferences.getInt(_stepsKey) ?? 6840;
  }

  @override
  Future<void> saveSteps(int steps) async {
    await sharedPreferences.setInt(_stepsKey, steps);
  }
}
