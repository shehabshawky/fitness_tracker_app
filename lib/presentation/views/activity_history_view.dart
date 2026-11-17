import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/activity_entity.dart';
import '../view_models/fitness_view_model.dart';
import '../widgets/activity_list_item_widget.dart';
import '../widgets/log_activity_dialog.dart';

class ActivityHistoryView extends StatefulWidget {
  final FitnessViewModel viewModel;

  const ActivityHistoryView({super.key, required this.viewModel});

  @override
  State<ActivityHistoryView> createState() => _ActivityHistoryViewState();
}

class _ActivityHistoryViewState extends State<ActivityHistoryView> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ActivityEntity> _filterActivities(List<ActivityEntity> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final query = _searchQuery.toLowerCase();
    return list.where((a) {
      return a.type.toLowerCase().contains(query) ||
          a.notes.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openLogActivity() async {
    final activity = await LogActivityDialog.show(context);
    if (activity != null) {
      await widget.viewModel.logActivity(activity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final allActivities = widget.viewModel.activities;
        final filtered = _filterActivities(allActivities);

        final totalWorkouts = allActivities.length;
        final totalCalories = allActivities.fold<int>(0, (sum, a) => sum + a.caloriesBurned);
        final totalMinutes = allActivities.fold<int>(0, (sum, a) => sum + a.durationMinutes);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Activity History',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.emerald.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '$totalWorkouts logged',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        color: AppTheme.emerald,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search workouts by exercise or notes...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Summary Stats Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131826) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? const Color(0xFF222B40) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'WORKOUTS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.emerald,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalWorkouts',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Container(height: 24, width: 1, color: isDark ? const Color(0xFF26324D) : const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          const Text(
                            'CALORIES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.calorieOrange,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalCalories kcal',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Container(height: 24, width: 1, color: isDark ? const Color(0xFF26324D) : const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          const Text(
                            'TOTAL TIME',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.electricCyan,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalMinutes min',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Activity List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isNotEmpty
                                    ? Icons.search_off_rounded
                                    : Icons.directions_run_outlined,
                                size: 54,
                                color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No workouts matched "$_searchQuery"'
                                    : 'No recorded activities found',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Try searching with another keyword'
                                    : 'Log your first workout session now!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 84),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final act = filtered[index];
                          return ActivityListItemWidget(
                            activity: act,
                            onDelete: () => widget.viewModel.deleteActivity(act.id),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.fitnessGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.emerald.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: _openLogActivity,
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Log Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
