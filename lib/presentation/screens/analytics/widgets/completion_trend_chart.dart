import 'package:analyzer/core/utils/app_strings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../controllers/analytics_controller.dart';

class CompletionTrendChart extends StatefulWidget {
  const CompletionTrendChart({super.key});

  @override
  State<CompletionTrendChart> createState() => _CompletionTrendChartState();
}

class _CompletionTrendChartState extends State<CompletionTrendChart> {
  final controller = Get.find<AnalyticsController>();
  int selectedRange = 7;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data =
          selectedRange == 7
              ? controller.last7DaysTrend
              : controller.last30DaysTrend;

      final avg =
          data.isEmpty ? 0.0 : data.reduce((a, b) => a + b) / data.length;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColorSecondary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.completionTrend,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppStrings.avg}: ${avg.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _rangeButton('7D', 7),
                      _rangeButton('30D', 30),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// Chart
            SizedBox(
              height: 220,
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        AppStrings.noDataYet,
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.white.withValues(alpha: 0.05),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 25,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => const Color(0xFF2D3561),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                return LineTooltipItem(
                                  '${spot.y.toStringAsFixed(0)}%',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                          handleBuiltInTouches: true,
                        ),
                        // Average line
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: avg,
                              color: AppColors.secondary.withValues(alpha: 0.4),
                              strokeWidth: 1,
                              dashArray: [6, 4],
                            ),
                          ],
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            curveSmoothness: 0.3,
                            spots: List.generate(
                              data.length,
                              (index) => FlSpot(
                                index.toDouble(),
                                data[index],
                              ),
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, xPercentage, bar, index) {
                                return FlDotCirclePainter(
                                  radius: 3,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: AppColors.primary,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.3),
                                  AppColors.primary.withValues(alpha: 0.05),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}