import 'package:analyzer/presentation/screens/analytics/widgets/analytics_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/analytics_controller.dart';
import 'widgets/completion_trend_chart.dart';
import 'widgets/heatmap_widget.dart';
import 'widgets/month_comparison_card.dart';
import 'widgets/overview_stats_card.dart';
import 'widgets/performance_score_card.dart';
import 'widgets/top_habits_card.dart';
import 'widgets/weekday_bar_chart.dart';
import 'widgets/weekly_summary_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Material(
      color: AppColors.background,
      child: Obx(() {
        final loading = controller.isLoading.value;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(
              position: slide,
              child: FadeTransition(opacity: animation, child: child),
            );
          },

          child: Skeletonizer(
            key: ValueKey(loading),
            enabled: loading,
            effect: ShimmerEffect(
              duration: Duration(milliseconds: 1200),
              baseColor: Colors.white.withValues(alpha: 0.07),
              highlightColor: Colors.white.withValues(alpha: 0.16),
            ),
            child: const _AnalyticsTab(),
          ),
        );
      }),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: const AnalyticsHeader(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const PerformanceScoreCard().animate().fadeIn().slideY(
                  begin: 0.1,
                ),
                const OverviewStatsCard().animate().fadeIn().slideY(begin: 0.1),
                const WeeklySummaryCard().animate().fadeIn().slideY(begin: 0.1),
                const CompletionTrendChart().animate().fadeIn().slideY(
                  begin: 0.1,
                ),
                const WeekdayBarChart().animate().fadeIn().slideY(begin: 0.1),
                const MonthComparisonCard().animate().fadeIn().slideY(
                  begin: 0.1,
                ),
                const TopHabitsCard().animate().fadeIn().slideY(begin: 0.1),
                const HeatmapWidget().animate().fadeIn().slideY(begin: 0.1),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
