import 'package:flutter/foundation.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/usecases/delete_activity_usecase.dart';
import '../../domain/usecases/get_activities_usecase.dart';
import '../../domain/usecases/get_daily_steps_usecase.dart';
import '../../domain/usecases/log_activity_usecase.dart';
import '../../domain/usecases/update_daily_steps_usecase.dart';

class DayActivitySummary {
  final String dayLabel; // e.g., 'M', 'T', 'W'
  final DateTime date;
  final int totalMinutes;
  final int totalCalories;
  final bool isToday;

  const DayActivitySummary({
    required this.dayLabel,
    required this.date,
    required this.totalMinutes,
    required this.totalCalories,
    required this.isToday,
  });
}

class FitnessViewModel extends ChangeNotifier {
  final GetActivitiesUseCase _getActivitiesUseCase;
  final LogActivityUseCase _logActivityUseCase;
  final DeleteActivityUseCase _deleteActivityUseCase;
  final GetDailyStepsUseCase _getDailyStepsUseCase;
  final UpdateDailyStepsUseCase _updateDailyStepsUseCase;

  FitnessViewModel({
    required this._getActivitiesUseCase,
    required this._logActivityUseCase,
    required this._deleteActivityUseCase,
    required this._getDailyStepsUseCase,
    required this._updateDailyStepsUseCase,
  });

  List<ActivityEntity> _activities = [];
  int _todaySteps = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Goals
  final int stepsGoal = 10000;
  final int caloriesGoal = 650;
  final int activeMinutesGoal = 45;

  List<ActivityEntity> get activities => List.unmodifiable(_activities);
  int get todaySteps => _todaySteps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<ActivityEntity> get todayActivities {
    final now = DateTime.now();
    return _activities.where((a) => _isSameDay(a.timestamp, now)).toList();
  }

  int get todayCaloriesBurned {
    // Workout calories burned + estimated steps calories (approx ~0.04 kcal per step)
    final workoutCals = todayActivities.fold<int>(0, (sum, a) => sum + a.caloriesBurned);
    final stepCals = (_todaySteps * 0.04).round();
    return workoutCals + stepCals;
  }

  int get todayActiveMinutes {
    return todayActivities.fold<int>(0, (sum, a) => sum + a.durationMinutes);
  }

  double get todayDistanceKm {
    return todayActivities.fold<double>(0.0, (sum, a) => sum + (a.distanceKm ?? 0.0));
  }

  double get stepsProgress => (todaySteps / stepsGoal).clamp(0.0, 1.0);
  double get caloriesProgress => (todayCaloriesBurned / caloriesGoal).clamp(0.0, 1.0);
  double get activeMinutesProgress => (todayActiveMinutes / activeMinutesGoal).clamp(0.0, 1.0);

  List<DayActivitySummary> get weeklySummaries {
    final now = DateTime.now();
    // Monday as start of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return List.generate(7, (index) {
      final dayDate = DateTime(monday.year, monday.month, monday.day + index);
      final dayActivities = _activities.where((a) => _isSameDay(a.timestamp, dayDate));
      final totalMins = dayActivities.fold<int>(0, (sum, a) => sum + a.durationMinutes);
      final totalCals = dayActivities.fold<int>(0, (sum, a) => sum + a.caloriesBurned);

      return DayActivitySummary(
        dayLabel: labels[index],
        date: dayDate,
        totalMinutes: totalMins,
        totalCalories: totalCals,
        isToday: _isSameDay(dayDate, now),
      );
    });
  }

  Future<void> loadFitnessData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _getActivitiesUseCase();
      _todaySteps = await _getDailyStepsUseCase();
    } catch (e) {
      _errorMessage = 'Failed to load fitness data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logActivity(ActivityEntity activity) async {
    try {
      await _logActivityUseCase(activity);
      _activities = List<ActivityEntity>.from(_activities)..insert(0, activity);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save activity: $e';
      notifyListeners();
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      await _deleteActivityUseCase(id);
      _activities = List<ActivityEntity>.from(_activities)..removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete activity: $e';
      notifyListeners();
    }
  }

  Future<void> addSteps(int count) async {
    _todaySteps += count;
    notifyListeners();
    await _updateDailyStepsUseCase(_todaySteps);
  }

  Future<void> setSteps(int value) async {
    _todaySteps = value;
    notifyListeners();
    await _updateDailyStepsUseCase(_todaySteps);
  }
}
