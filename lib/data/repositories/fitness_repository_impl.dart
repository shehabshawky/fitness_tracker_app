import '../../domain/entities/activity_entity.dart';
import '../../domain/repositories/fitness_repository.dart';
import '../datasources/fitness_local_data_source.dart';
import '../models/activity_model.dart';

class FitnessRepositoryImpl implements FitnessRepository {
  final FitnessLocalDataSource localDataSource;

  FitnessRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ActivityEntity>> getActivities() async {
    final models = await localDataSource.getActivities();
    return models;
  }

  @override
  Future<void> logActivity(ActivityEntity activity) async {
    final models = await localDataSource.getActivities();
    models.insert(0, ActivityModel.fromEntity(activity));
    await localDataSource.saveActivities(models);
  }

  @override
  Future<void> deleteActivity(String id) async {
    final models = await localDataSource.getActivities();
    models.removeWhere((a) => a.id == id);
    await localDataSource.saveActivities(models);
  }

  @override
  Future<int> getTodaySteps() async {
    return await localDataSource.getSteps();
  }

  @override
  Future<void> updateTodaySteps(int steps) async {
    await localDataSource.saveSteps(steps);
  }
}
