import 'package:analyzer/presentation/screens/analytics/widgets/completion_trend_chart.dart';
import 'package:analyzer/presentation/screens/analytics/widgets/correlation_card.dart';
import 'package:analyzer/presentation/screens/analytics/widgets/heatmap_widget.dart';
import 'package:analyzer/presentation/screens/analytics/widgets/month_comparison_card.dart';
import 'package:analyzer/presentation/screens/analytics/widgets/top_habits_card.dart';
import 'package:analyzer/presentation/screens/analytics/widgets/weekday_bar_chart.dart';
import 'package:analyzer/presentation/screens/analytics/widgets/weekly_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/analytics_controller.dart';
import 'widgets/performance_score_card.dart';
import 'widgets/overview_stats_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
        );
      }

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              PerformanceScoreCard(),
              SizedBox(height: 24),
              //OverviewStatsCard(),
              SizedBox(height: 24),
              WeeklySummaryCard(),
              SizedBox(height: 24),
              CompletionTrendChart(),
              SizedBox(height: 24),
              WeekdayBarChart(),
              SizedBox(height: 24),
              MonthComparisonCard(),
              SizedBox(height: 24),
              TopHabitsCard(),
              SizedBox(height: 24),
              //CorrelationCard(),
              SizedBox(height: 24),
              HeatmapWidget(),
            ],
          ),
        ),
      );
    });
  }
}
