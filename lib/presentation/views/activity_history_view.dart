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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.transparent : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Text(
                      '$totalWorkouts entries',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: isDark ? const Color(0xFF93C5FD) : AppTheme.classicNavy,
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
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'ENTRIES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.classicNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalWorkouts',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(height: 24, width: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          const Text(
                            'TOTAL CALORIES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.athleticCrimson,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalCalories kcal',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(height: 24, width: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          const Text(
                            'ACTIVE TIME',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalMinutes min',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

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
                                    ? Icons.search_off
                                    : Icons.directions_run,
                                size: 48,
                                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No workouts matched "$_searchQuery"'
                                    : 'No recorded activities',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Try searching with another keyword'
                                    : 'Log your first workout session now',
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
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openLogActivity,
            backgroundColor: isDark ? const Color(0xFF2563EB) : AppTheme.classicNavy,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Log Activity', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
