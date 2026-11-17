import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/fitness_local_data_source.dart';
import '../../data/repositories/fitness_repository_impl.dart';
import '../../domain/repositories/fitness_repository.dart';
import '../../domain/usecases/delete_activity_usecase.dart';
import '../../domain/usecases/get_activities_usecase.dart';
import '../../domain/usecases/get_daily_steps_usecase.dart';
import '../../domain/usecases/log_activity_usecase.dart';
import '../../domain/usecases/update_daily_steps_usecase.dart';
import '../../presentation/view_models/fitness_view_model.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _registry = {};

  void registerSingleton<T>(T instance) {
    _registry[T] = instance;
  }

  T get<T>() {
    final service = _registry[T];
    if (service == null) {
      throw Exception('Service of type $T is not registered in ServiceLocator');
    }
    return service as T;
  }
}

final sl = ServiceLocator();

Future<void> initDependencies({SharedPreferences? mockPrefs}) async {
  // External
  final prefs = mockPrefs ?? await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Data Sources
  final localDataSource = FitnessLocalDataSourceImpl(sharedPreferences: sl.get<SharedPreferences>());
  sl.registerSingleton<FitnessLocalDataSource>(localDataSource);

  // Repositories
  final repository = FitnessRepositoryImpl(localDataSource: sl.get<FitnessLocalDataSource>());
  sl.registerSingleton<FitnessRepository>(repository);

  // Use Cases
  sl.registerSingleton<GetActivitiesUseCase>(GetActivitiesUseCase(sl.get<FitnessRepository>()));
  sl.registerSingleton<LogActivityUseCase>(LogActivityUseCase(sl.get<FitnessRepository>()));
  sl.registerSingleton<DeleteActivityUseCase>(DeleteActivityUseCase(sl.get<FitnessRepository>()));
  sl.registerSingleton<GetDailyStepsUseCase>(GetDailyStepsUseCase(sl.get<FitnessRepository>()));
  sl.registerSingleton<UpdateDailyStepsUseCase>(UpdateDailyStepsUseCase(sl.get<FitnessRepository>()));

  // View Models
  final viewModel = FitnessViewModel(
    getActivitiesUseCase: sl.get<GetActivitiesUseCase>(),
    logActivityUseCase: sl.get<LogActivityUseCase>(),
    deleteActivityUseCase: sl.get<DeleteActivityUseCase>(),
    getDailyStepsUseCase: sl.get<GetDailyStepsUseCase>(),
    updateDailyStepsUseCase: sl.get<UpdateDailyStepsUseCase>(),
  );
  sl.registerSingleton<FitnessViewModel>(viewModel);
}
