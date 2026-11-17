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
            content: Row(
              children: [
                Text(activity.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text('${activity.type} session logged!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.emerald,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final todayFormatted = DateFormat('EEEE, MMM d').format(DateTime.now());

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.emerald),
            ),
          );
        }

        final todayList = widget.viewModel.todayActivities;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: AppTheme.fitnessGradient,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.emerald.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PulseFit',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      todayFormatted,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'All Activities History',
                icon: const Icon(Icons.history_rounded),
                onPressed: _openHistory,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.fitnessGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.emerald.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: _openLogActivity,
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'Log',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 3 Key Metrics Cards
                  Row(
                    children: [
                      Expanded(
                        child: MetricCardWidget(
                          title: 'Steps',
                          icon: '👟',
                          value: NumberFormat('#,###').format(widget.viewModel.todaySteps),
                          goalText: 'Goal: 10,000',
                          progress: widget.viewModel.stepsProgress,
                          progressGradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF34D399)],
                          ),
                          accentColor: AppTheme.emerald,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCardWidget(
                          title: 'Burned',
                          icon: '🔥',
                          value: '${widget.viewModel.todayCaloriesBurned}',
                          unit: 'kcal',
                          goalText: 'Goal: 650 kcal',
                          progress: widget.viewModel.caloriesProgress,
                          progressGradient: AppTheme.calorieGradient,
                          accentColor: AppTheme.calorieOrange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCardWidget(
                          title: 'Active',
                          icon: '⏱️',
                          value: '${widget.viewModel.todayActiveMinutes}',
                          unit: 'min',
                          goalText: 'Goal: 45 min',
                          progress: widget.viewModel.activeMinutesProgress,
                          progressGradient: const LinearGradient(
                            colors: [Color(0xFF06B6D4), Color(0xFF38BDF8)],
                          ),
                          accentColor: AppTheme.electricCyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Steps Tracker Widget
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131826) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF222B40) : const Color(0xFFE2E8F0),
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QUICK STEP LOGGER',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: AppTheme.emerald,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to log walk or run steps',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => widget.viewModel.addSteps(500),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text('+500', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                            const SizedBox(width: 6),
                            OutlinedButton(
                              onPressed: () => widget.viewModel.addSteps(1000),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text('+1,000', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.fitnessGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextButton(
                                onPressed: () => widget.viewModel.addSteps(2500),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text(
                                  '+2,500',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Weekly Bar Chart Widget
                  WeeklyChartWidget(
                    weeklySummaries: widget.viewModel.weeklySummaries,
                  ),
                  const SizedBox(height: 20),

                  // Today's Workouts Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TODAY'S WORKOUTS (${todayList.length})",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppTheme.emerald,
                        ),
                      ),
                      TextButton(
                        onPressed: _openHistory,
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.electricCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Activities List or Empty State
                  if (todayList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131826) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF222B40) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 44,
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No workouts logged today',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap "Log" in the top bar to record your exercise',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
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
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.fitnessGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.emerald.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: _openLogActivity,
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Log Workout',
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
