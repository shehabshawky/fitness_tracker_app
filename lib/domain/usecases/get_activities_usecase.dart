import '../entities/activity_entity.dart';
import '../repositories/fitness_repository.dart';

class GetActivitiesUseCase {
  final FitnessRepository repository;

  GetActivitiesUseCase(this.repository);

  Future<List<ActivityEntity>> call() async {
    return await repository.getActivities();
  }
}
