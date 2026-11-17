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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppTheme.classicNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Exercise duration (minutes)',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.transparent : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Text(
                  '$totalWeekMinutes mins total',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF93C5FD) : AppTheme.classicNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 115,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklySummaries.map((day) {
                final double factor = maxMinutes > 0
                    ? (day.totalMinutes / maxMinutes).clamp(0.08, 1.0)
                    : 0.08;

                final isToday = day.isToday;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (day.totalMinutes > 0)
                        Text(
                          '${day.totalMinutes}m',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            color: isToday
                                ? (isDark ? const Color(0xFF60A5FA) : AppTheme.classicNavy)
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          ),
                        )
                      else
                        const SizedBox(height: 12),
                      const SizedBox(height: 4),
                      Container(
                        width: 20,
                        height: 70 * factor,
                        decoration: BoxDecoration(
                          color: isToday
                              ? (isDark ? const Color(0xFF3B82F6) : AppTheme.classicNavy)
                              : (day.totalMinutes > 0
                                  ? (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1))
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9))),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day.dayLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          color: isToday
                              ? (isDark ? const Color(0xFF60A5FA) : AppTheme.classicNavy)
                              : (isDark ? Colors.grey.shade400 : const Color(0xFF64748B)),
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
