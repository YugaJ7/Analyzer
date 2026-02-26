import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/analytics_controller.dart';

class HeatmapWidget extends StatelessWidget {
  const HeatmapWidget({super.key});

  static const Color cardColor = Color(0xFF1E2749);
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color accentColor = Color(0xFF4ECDC4);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Obx(() {
      if (controller.heatmapData.isEmpty) {
        return const SizedBox();
      }

      final sortedDates = controller.heatmapData.keys.toList()
        ..sort();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Habit Heat Map",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            /// Horizontal scroll for months
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeekdayColumn(),
                  const SizedBox(width: 12),
                  _buildMonthGrid(sortedDates, controller),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Weekday labels (M T W T F S S)
  Widget _buildWeekdayColumn() {
    const labels = ["M", "T", "W", "T", "F", "S", "S"];

    return Column(
      children: labels
          .map(
            (e) => Container(
              height: 26,
              alignment: Alignment.center,
              child: Text(
                e,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// Month Grid
  Widget _buildMonthGrid(
      List<DateTime> dates,
      AnalyticsController controller) {
    final Map<String, List<DateTime>> months = {};

    for (final date in dates) {
      final key = "${date.year}-${date.month}";
      months.putIfAbsent(key, () => []);
      months[key]!.add(date);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: months.entries.map((entry) {
        final monthDates = entry.value;
        final monthLabel =
            "${_monthName(monthDates.first.month)} ${monthDates.first.year}";

        return Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                monthLabel,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _buildMonthColumns(monthDates, controller),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build weekly columns
  Widget _buildMonthColumns(
      List<DateTime> monthDates,
      AnalyticsController controller) {
    monthDates.sort();

    final Map<int, List<DateTime>> weekColumns = {};

    for (final date in monthDates) {
      final weekIndex = _weekOfMonth(date);
      weekColumns.putIfAbsent(weekIndex, () => []);
      weekColumns[weekIndex]!.add(date);
    }

    return Row(
      children: weekColumns.entries.map((entry) {
        final days = entry.value;

        return Column(
          children: List.generate(7, (i) {
            final day = days.firstWhereOrNull(
                (d) => d.weekday == i + 1);

            if (day == null) {
              return _emptyBox();
            }

            final percent =
                controller.heatmapData[day] ?? 0;

            return _heatBox(percent);
          }),
        );
      }).toList(),
    );
  }

  Widget _heatBox(double percent) {
    return Container(
      margin: const EdgeInsets.all(3),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: _colorFromPercent(percent),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _emptyBox() {
    return Container(
      margin: const EdgeInsets.all(3),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Color _colorFromPercent(double percent) {
    if (percent == 0) return Colors.white10;

    if (percent < 25) {
      return accentColor.withOpacity(0.3);
    } else if (percent < 50) {
      return accentColor.withOpacity(0.5);
    } else if (percent < 75) {
      return accentColor.withOpacity(0.7);
    } else {
      return accentColor;
    }
  }

  int _weekOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return ((date.day + firstDay.weekday - 1) / 7).floor();
  }

  String _monthName(int month) {
    const names = [
      "Jan", "Feb", "Mar", "Apr",
      "May", "Jun", "Jul", "Aug",
      "Sep", "Oct", "Nov", "Dec"
    ];
    return names[month - 1];
  }
}