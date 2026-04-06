import 'package:analyzer/core/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../controllers/analytics_controller.dart';

class OverviewStatsCard extends StatelessWidget {
  const OverviewStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Obx(() {
      final trackedDays = controller.heatmapData.entries
          .where((e) => e.value > 0)
          .length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.overview,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _OverviewTile(
                icon: Icons.track_changes_rounded,
                iconColor: AppColors.primary,
                title: AppStrings.activeHabits,
                value: controller.totalActiveHabits.value.toString(),
              ),
              const SizedBox(width: 12),
              _OverviewTile(
                icon: Icons.percent_rounded,
                iconColor: AppColors.secondary,
                title: AppStrings.completion,
                value: '${controller.overallCompletionRate.value.toStringAsFixed(0)}%',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _OverviewTile(
                icon: Icons.emoji_events_rounded,
                iconColor: AppColors.orange,
                title: AppStrings.bestStreak,
                value: controller.overallBestStreak.value.toString(),
              ),
              const SizedBox(width: 12),
              _OverviewTile(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.error,
                title: AppStrings.trackedDays,
                value: trackedDays.toString(),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _OverviewTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _OverviewTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}