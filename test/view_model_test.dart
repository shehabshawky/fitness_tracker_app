import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker_app/core/di/service_locator.dart';
import 'package:fitness_tracker_app/domain/entities/activity_entity.dart';
import 'package:fitness_tracker_app/presentation/view_models/fitness_view_model.dart';

void main() {
  late FitnessViewModel viewModel;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
    viewModel = sl.get<FitnessViewModel>();
  });

  group('FitnessViewModel Clean Architecture Tests', () {
    test('initial state loads seed activities and steps', () async {
      await viewModel.loadFitnessData();

      expect(viewModel.activities.isNotEmpty, isTrue);
      expect(viewModel.todaySteps, greaterThan(0));
      expect(viewModel.todayCaloriesBurned, greaterThan(0));
      expect(viewModel.weeklySummaries.length, equals(7));
    });

    test('addSteps increments today steps and updates progress', () async {
      await viewModel.loadFitnessData();
      final initialSteps = viewModel.todaySteps;

      await viewModel.addSteps(1000);

      expect(viewModel.todaySteps, equals(initialSteps + 1000));
      expect(viewModel.stepsProgress, greaterThan(0.0));
    });

    test('logActivity prepends new workout and updates calories & minutes', () async {
      await viewModel.loadFitnessData();
      final initialCount = viewModel.activities.length;
      final initialCalories = viewModel.todayCaloriesBurned;

      final workout = ActivityEntity(
        id: 'test_run_1',
        type: 'Running',
        icon: '🏃',
        durationMinutes: 30,
        caloriesBurned: 300,
        distanceKm: 5.0,
        notes: 'Test run',
        timestamp: DateTime.now(),
      );

      await viewModel.logActivity(workout);

      expect(viewModel.activities.length, equals(initialCount + 1));
      expect(viewModel.activities.first.id, equals('test_run_1'));
      expect(viewModel.todayCaloriesBurned, equals(initialCalories + 300));
    });

    test('deleteActivity removes workout by id', () async {
      await viewModel.loadFitnessData();
      final initialCount = viewModel.activities.length;
      final targetId = viewModel.activities.first.id;

      await viewModel.deleteActivity(targetId);

      expect(viewModel.activities.length, equals(initialCount - 1));
      expect(viewModel.activities.any((a) => a.id == targetId), isFalse);
    });
  });
}
