import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/analytics_controller.dart';

class HeatmapWidget extends StatelessWidget {
  const HeatmapWidget({super.key});

  static const Color _emptyColor = Color(0xFF151B36);
  static const List<Color> _heatColors = [
    Color(0xFF1a2340), // 0%  — near-empty
    Color(0xFF2A4858), // 1-25%
    Color(0xFF2E7D6E), // 25-50%
    Color(0xFF3EB489), // 50-75%
    Color(0xFF4ECDC4), // 75-100%
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Obx(() {
      if (controller.heatmapData.isEmpty) {
        return const SizedBox.shrink();
      }

      // Only show the last 90 days for a cleaner view 
      final now = DateTime.now();
      final cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 90));
      
      final filteredEntries = controller.heatmapData.entries
          .where((e) => e.key.isAfter(cutoff) || e.key.isAtSameMomentAs(cutoff))
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      if (filteredEntries.isEmpty) {
        return const SizedBox.shrink();
      }

      // Build week columns
      final weeks = <List<_DayData>>[];
      List<_DayData> currentWeek = [];

      // Fill leading blanks for first week
      final firstDate = filteredEntries.first.key;
      final startWeekday = firstDate.weekday; // 1=Mon, 7=Sun
      for (int i = 1; i < startWeekday; i++) {
        currentWeek.add(_DayData.empty());
      }

      final dataMap = Map.fromEntries(filteredEntries);

      // Iterate through each day
      DateTime cursor = firstDate;
      final lastDate = filteredEntries.last.key;

      while (!cursor.isAfter(lastDate)) {
        if (cursor.weekday == 1 && currentWeek.isNotEmpty) {
          weeks.add(currentWeek);
          currentWeek = [];
        }

        final percent = dataMap[cursor] ?? 0.0;
        currentWeek.add(_DayData(date: cursor, percent: percent));
        cursor = cursor.add(const Duration(days: 1));
      }

      // Add remaining week
      if (currentWeek.isNotEmpty) {
        weeks.add(currentWeek);
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2749),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity Heatmap',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Last 90 days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Heatmap grid
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekday labels
                  Column(
                    children: const [
                      _DayLabel('M'),
                      _DayLabel('T'),
                      _DayLabel('W'),
                      _DayLabel('T'),
                      _DayLabel('F'),
                      _DayLabel('S'),
                      _DayLabel('S'),
                    ],
                  ),
                  const SizedBox(width: 6),
                  // Week columns
                  ...weeks.map((week) {
                    return Column(
                      children: List.generate(7, (dayIndex) {
                        if (dayIndex < week.length) {
                          return _HeatCell(data: week[dayIndex]);
                        }
                        return _HeatCell(data: _DayData.empty());
                      }),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Less',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 6),
                ..._heatColors.map(
                  (color) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'More',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  static Color colorFromPercent(double percent) {
    if (percent <= 0) return _emptyColor;
    if (percent < 25) return _heatColors[1];
    if (percent < 50) return _heatColors[2];
    if (percent < 75) return _heatColors[3];
    return _heatColors[4];
  }
}

class _DayData {
  final DateTime? date;
  final double percent;
  final bool isEmpty;

  _DayData({this.date, this.percent = 0})
      : isEmpty = date == null;

  factory _DayData.empty() => _DayData();
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  final _DayData data;
  const _HeatCell({required this.data});

  @override
  Widget build(BuildContext context) {
    final isToday = data.date != null &&
        data.date!.year == DateTime.now().year &&
        data.date!.month == DateTime.now().month &&
        data.date!.day == DateTime.now().day;

    return GestureDetector(
      onTap: data.isEmpty
          ? null
          : () {
              final dateStr = DateFormat('MMM dd, yyyy').format(data.date!);
              Get.snackbar(
                dateStr,
                '${data.percent.toStringAsFixed(0)}% completed',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF2D3561),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(12),
                borderRadius: 12,
              );
            },
      child: Container(
        margin: const EdgeInsets.all(2),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: data.isEmpty
              ? Colors.transparent
              : HeatmapWidget.colorFromPercent(data.percent),
          borderRadius: BorderRadius.circular(4),
          border: isToday
              ? Border.all(color: Colors.white, width: 1.5)
              : null,
        ),
      ),
    );
  }
}