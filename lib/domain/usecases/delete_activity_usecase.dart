import '../repositories/fitness_repository.dart';

class DeleteActivityUseCase {
  final FitnessRepository repository;

  DeleteActivityUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteActivity(id);
  }
}
