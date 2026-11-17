import '../entities/activity_entity.dart';
import '../repositories/fitness_repository.dart';

class LogActivityUseCase {
  final FitnessRepository repository;

  LogActivityUseCase(this.repository);

  Future<void> call(ActivityEntity activity) async {
    return await repository.logActivity(activity);
  }
}
