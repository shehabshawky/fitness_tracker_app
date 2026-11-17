import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../view_models/fitness_view_model.dart';
import '../widgets/activity_list_item_widget.dart';
import '../widgets/log_activity_dialog.dart';
import '../widgets/metric_card_widget.dart';
import '../widgets/weekly_chart_widget.dart';
import 'activity_history_view.dart';

class DashboardView extends StatefulWidget {
  final FitnessViewModel viewModel;

  const DashboardView({super.key, required this.viewModel});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.activities.isEmpty && !widget.viewModel.isLoading) {
        widget.viewModel.loadFitnessData();
      }
    });
  }

  Future<void> _openLogActivity() async {
    final activity = await LogActivityDialog.show(context);
    if (activity != null) {
      await widget.viewModel.logActivity(activity);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${activity.icon} ${activity.type} logged successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.classicNavy,
          ),
        );
      }
    }
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityHistoryView(viewModel: widget.viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final todayFormatted = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.classicNavy),
            ),
          );
        }

        final todayList = widget.viewModel.todayActivities;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fitness Tracker',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  todayFormatted,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.normal,
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Activity History',
                icon: const Icon(Icons.history_rounded),
                onPressed: _openHistory,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton.icon(
                  onPressed: _openLogActivity,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Log'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF2563EB) : AppTheme.classicNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 3 Classic Metric Cards
                  Row(
                    children: [
                      Expanded(
                        child: MetricCardWidget(
                          title: 'Steps',
                          icon: '👟',
                          value: NumberFormat('#,###').format(widget.viewModel.todaySteps),
                          goalText: 'of 10,000 goal',
                          progress: widget.viewModel.stepsProgress,
                          accentColor: isDark ? const Color(0xFF38BDF8) : AppTheme.royalBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MetricCardWidget(
                          title: 'Calories',
                          icon: '🔥',
                          value: '${widget.viewModel.todayCaloriesBurned}',
                          unit: 'kcal',
                          goalText: 'of 650 kcal goal',
                          progress: widget.viewModel.caloriesProgress,
                          accentColor: AppTheme.athleticCrimson,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MetricCardWidget(
                          title: 'Active',
                          icon: '⏱️',
                          value: '${widget.viewModel.todayActiveMinutes}',
                          unit: 'min',
                          goalText: 'of 45 min goal',
                          progress: widget.viewModel.activeMinutesProgress,
                          accentColor: AppTheme.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Steps Tracker
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QUICK STEPS LOGGER',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.classicNavy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Log daily steps recorded',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => widget.viewModel.addSteps(500),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text('+500', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            const SizedBox(width: 6),
                            OutlinedButton(
                              onPressed: () => widget.viewModel.addSteps(1000),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text('+1,000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            const SizedBox(width: 6),
                            FilledButton(
                              onPressed: () => widget.viewModel.addSteps(2500),
                              style: FilledButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF2563EB) : AppTheme.classicNavy,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text('+2,500', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Weekly Activity Chart
                  WeeklyChartWidget(
                    weeklySummaries: widget.viewModel.weeklySummaries,
                  ),
                  const SizedBox(height: 16),

                  // Today's Workouts Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TODAY'S WORKOUTS (${todayList.length})",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: AppTheme.classicNavy,
                        ),
                      ),
                      TextButton(
                        onPressed: _openHistory,
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF60A5FA) : AppTheme.classicNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Workouts List
                  if (todayList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.fitness_center_outlined,
                              size: 36,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No workouts logged today',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap "Log" to record your fitness activities',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final act = todayList[index];
                        return ActivityListItemWidget(
                          activity: act,
                          onDelete: () => widget.viewModel.deleteActivity(act.id),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
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
