import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/activity_entity.dart';

class ActivityListItemWidget extends StatelessWidget {
  final ActivityEntity activity;
  final VoidCallback onDelete;

  const ActivityListItemWidget({
    super.key,
    required this.activity,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('hh:mm a').format(activity.timestamp);
    final dateStr = DateFormat('MMM dd').format(activity.timestamp);

    return Container(
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
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.transparent : const Color(0xFFBFDBFE),
              ),
            ),
            child: Center(
              child: Text(
                activity.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.type,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$dateStr · $timeStr',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '⏱️ ${activity.durationMinutes} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('·', style: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400)),
                    const SizedBox(width: 8),
                    Text(
                      '🔥 ${activity.caloriesBurned} kcal',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.athleticCrimson,
                      ),
                    ),
                    if (activity.distanceKm != null && activity.distanceKm! > 0) ...[
                      const SizedBox(width: 8),
                      Text('·', style: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400)),
                      const SizedBox(width: 8),
                      Text(
                        '📍 ${activity.distanceKm!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF38BDF8) : AppTheme.classicNavy,
                        ),
                      ),
                    ],
                  ],
                ),
                if (activity.notes.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    activity.notes,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 19),
            color: Colors.redAccent,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  title: const Text('Delete Activity?'),
                  content: Text('Remove this ${activity.type} workout record?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                onDelete();
              }
            },
          ),
        ],
      ),
    );
  }
}
