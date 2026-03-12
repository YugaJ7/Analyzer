import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/analytics_controller.dart';

class CompletionTrendChart extends StatefulWidget {
  const CompletionTrendChart({super.key});

  @override
  State<CompletionTrendChart> createState() =>
      _CompletionTrendChartState();
}

class _CompletionTrendChartState
    extends State<CompletionTrendChart> {
  final controller = Get.find<AnalyticsController>();

  int selectedRange = 7; // 7 or 30

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = selectedRange == 7
          ? controller.last7DaysTrend
          : controller.last30DaysTrend;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2749),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Completion Trend",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    _rangeButton("7D", 7),
                    const SizedBox(width: 8),
                    _rangeButton("30D", 30),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),

            /// Chart
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData:
                      FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: List.generate(
                        data.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          data[index],
                        ),
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData:
                          const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C63FF)
                                .withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF4ECDC4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _rangeButton(String label, int value) {
    final isSelected = selectedRange == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRange = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6C63FF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}