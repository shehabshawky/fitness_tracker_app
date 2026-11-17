import '../repositories/fitness_repository.dart';

class UpdateDailyStepsUseCase {
  final FitnessRepository repository;

  UpdateDailyStepsUseCase(this.repository);

  Future<void> call(int steps) async {
    return await repository.updateTodaySteps(steps);
  }
}
