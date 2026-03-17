import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
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

    return Obx(() {
      if (controller.isLoading.value) {
        return const _AnalyticsSkeleton();
      }

      return SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analytics',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ).animate().fadeIn().slideX(begin: -0.15),
                            const SizedBox(height: 4),
                            Text(
                              'Your habit insights',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ).animate().fadeIn(delay: 100.ms),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            color: Color(0xFF6C63FF),
                            size: 26,
                          ),
                        ).animate().scale(delay: 200.ms),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const PerformanceScoreCard()
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  const OverviewStatsCard()
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  const WeeklySummaryCard()
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  const CompletionTrendChart()
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  const WeekdayBarChart()
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  const MonthComparisonCard()
                      .animate()
                      .fadeIn(delay: 600.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  const TopHabitsCard()
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  const HeatmapWidget()
                      .animate()
                      .fadeIn(delay: 800.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Skeleton loading for the analytics screen
class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  Widget _shimmerBox({
    required double height,
    double? width,
    BorderRadius? radius,
  }) {
    return Container(
          height: height,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: radius ?? BorderRadius.circular(12),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.12),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(height: 28, width: 120),
                    const SizedBox(height: 6),
                    _shimmerBox(height: 14, width: 160),
                  ],
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Performance score skeleton
            _shimmerBox(
              height: 240,
              radius: BorderRadius.circular(24),
            ),
            const SizedBox(height: 20),

            // Overview stats skeleton
            _shimmerBox(height: 22, width: 100),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _shimmerBox(
                    height: 80,
                    radius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _shimmerBox(
                    height: 80,
                    radius: BorderRadius.circular(18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _shimmerBox(
                    height: 80,
                    radius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _shimmerBox(
                    height: 80,
                    radius: BorderRadius.circular(18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Chart skeletons
            _shimmerBox(
              height: 100,
              radius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 20),
            _shimmerBox(
              height: 280,
              radius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 20),
            _shimmerBox(
              height: 280,
              radius: BorderRadius.circular(20),
            ),
          ],
        ),
      ),
    );
  }
}
