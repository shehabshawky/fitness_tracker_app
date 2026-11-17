import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../view_models/fitness_view_model.dart';

class WeeklyChartWidget extends StatelessWidget {
  final List<DayActivitySummary> weeklySummaries;

  const WeeklyChartWidget({super.key, required this.weeklySummaries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final maxMinutes = weeklySummaries.fold<int>(
      60,
      (max, day) => day.totalMinutes > max ? day.totalMinutes : max,
    );

    final totalWeekMinutes = weeklySummaries.fold<int>(
      0,
      (sum, day) => sum + day.totalMinutes,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131826) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF222B40) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WEEKLY ACTIVITY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppTheme.emerald,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Daily exercise duration',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.emerald.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  '$totalWeekMinutes mins total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Visual Bars
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklySummaries.map((day) {
                final double factor = maxMinutes > 0
                    ? (day.totalMinutes / maxMinutes).clamp(0.08, 1.0)
                    : 0.08;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Active minutes text
                      if (day.totalMinutes > 0)
                        Text(
                          '${day.totalMinutes}m',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: day.isToday ? FontWeight.w800 : FontWeight.w600,
                            color: day.isToday
                                ? AppTheme.emerald
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          ),
                        )
                      else
                        const SizedBox(height: 12),
                      const SizedBox(height: 4),

                      // Bar
                      Container(
                        width: 24,
                        height: 75 * factor,
                        decoration: BoxDecoration(
                          gradient: day.isToday ? AppTheme.fitnessGradient : null,
                          color: day.isToday
                              ? null
                              : (day.totalMinutes > 0
                                  ? AppTheme.emerald.withValues(alpha: 0.3)
                                  : (isDark ? const Color(0xFF1E283E) : const Color(0xFFF1F5F9))),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: day.isToday
                              ? [
                                  BoxShadow(
                                    color: AppTheme.emerald.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Day letter (M, T, W, ...)
                      Text(
                        day.dayLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: day.isToday ? FontWeight.w800 : FontWeight.w600,
                          color: day.isToday
                              ? AppTheme.emerald
                              : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
