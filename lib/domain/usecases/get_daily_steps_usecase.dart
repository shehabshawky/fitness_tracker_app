import '../repositories/fitness_repository.dart';

class GetDailyStepsUseCase {
  final FitnessRepository repository;

  GetDailyStepsUseCase(this.repository);

  Future<int> call() async {
    return await repository.getTodaySteps();
  }
}
