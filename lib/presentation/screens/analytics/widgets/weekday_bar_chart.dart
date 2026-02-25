import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/analytics_controller.dart';

class WeekdayBarChart extends StatelessWidget {
  const WeekdayBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Obx(() {
      final data = controller.weekdayBreakdown;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2749),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekday Breakdown",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  gridData:
                      const FlGridData(show: false),
                  borderData:
                      FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget:
                            (value, meta) {
                          const days = [
                            "",
                            "M",
                            "T",
                            "W",
                            "T",
                            "F",
                            "S",
                            "S"
                          ];
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(
                                color: Colors.white70),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(7, (index) {
                    final weekday = index + 1;
                    final value =
                        data[weekday] ?? 0.0;

                    return BarChartGroupData(
                      x: weekday,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          width: 14,
                          borderRadius:
                              BorderRadius.circular(6),
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xFF6C63FF),
                              Color(0xFF4ECDC4),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}