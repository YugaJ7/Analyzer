import 'package:analyzer/core/utils/app_strings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../controllers/analytics_controller.dart';

class WeekdayBarChart extends StatefulWidget {
  const WeekdayBarChart({super.key});

  @override
  State<WeekdayBarChart> createState() => _WeekdayBarChartState();
}

class _WeekdayBarChartState extends State<WeekdayBarChart> {
  final controller = Get.find<AnalyticsController>();
  bool showCurrentWeek = true;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = showCurrentWeek
          ? controller.currentWeekBreakdown
          : controller.weekdayBreakdown;

      // Find the best day
      int bestDay = 1;
      double bestValue = 0;
      data.forEach((day, val) {
        if (val > bestValue) {
          bestValue = val;
          bestDay = day;
        }
      });

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColorSecondary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.weekdayBreakdown,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (bestValue > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${AppStrings.best}: ${_dayLabels[bestDay - 1]} (${bestValue.toStringAsFixed(0)}%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _rangeButton(AppStrings.week, true),
                        _rangeButton(AppStrings.avg, false),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
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
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => const Color(0xFF2D3561),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toStringAsFixed(0)}%',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt() - 1;
                            if (idx < 0 || idx >= _dayLabels.length) {
                              return const SizedBox();
                            }
                            final isBest =
                                value.toInt() == bestDay && bestValue > 0;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _dayLabels[idx],
                                style: TextStyle(
                                  color: isBest
                                      ? AppColors.secondary
                                      : Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: isBest
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(7, (index) {
                      final weekday = index + 1;
                      final value = data[weekday] ?? 0.0;
                      final isBest = weekday == bestDay && bestValue > 0;

                      return BarChartGroupData(
                        x: weekday,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            width: 20,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            gradient: isBest
                                ? LinearGradient(
                                    colors: [
                                      AppColors.secondary,
                                      AppColors.primary,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  )
                                : LinearGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.6),
                                      AppColors.primary,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 100,
                              color: Colors.white.withValues(alpha: 0.04),
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
        ),
      );
    });
  }

  Widget _rangeButton(String label, bool isWeek) {
    final isSelected = showCurrentWeek == isWeek;

    return GestureDetector(
      onTap: () {
        setState(() {
          showCurrentWeek = isWeek;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
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
