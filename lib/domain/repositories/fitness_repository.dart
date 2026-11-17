import '../entities/activity_entity.dart';

abstract class FitnessRepository {
  Future<List<ActivityEntity>> getActivities();
  Future<void> logActivity(ActivityEntity activity);
  Future<void> deleteActivity(String id);
  Future<int> getTodaySteps();
  Future<void> updateTodaySteps(int steps);
}
