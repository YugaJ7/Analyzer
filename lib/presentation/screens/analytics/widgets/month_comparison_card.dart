import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/analytics_controller.dart';

class MonthComparisonCard extends StatelessWidget {
  const MonthComparisonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Obx(() {
      final diff = controller.monthComparison.value;
      final isPositive = diff >= 0;
      final overallRate = controller.overallCompletionRate.value;
      final thisMonthRate = overallRate + diff;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Comparison',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositive
                            ? const Color(0xFF4ECDC4)
                            : const Color(0xFFFF6B6B))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 16,
                        color: isPositive
                            ? const Color(0xFF4ECDC4)
                            : const Color(0xFFFF6B6B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${diff.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isPositive
                              ? const Color(0xFF4ECDC4)
                              : const Color(0xFFFF6B6B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // This Month bar
            _ComparisonBar(
              label: 'This Month',
              value: thisMonthRate.clamp(0, 100),
              color: const Color(0xFF6C63FF),
            ),
            const SizedBox(height: 14),

            // Overall Average bar
            _ComparisonBar(
              label: 'Overall Avg',
              value: overallRate.clamp(0, 100),
              color: const Color(0xFF4ECDC4),
            ),
          ],
        ),
      );
    });
  }
}

class _ComparisonBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ComparisonBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value / 100),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, _) {
            return Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: animValue,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.6),
                        color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}