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

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2749),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isPositive
                  ? Icons.trending_up
                  : Icons.trending_down,
              color: isPositive
                  ? Colors.green
                  : Colors.red,
            ),
            const SizedBox(width: 12),
            Text(
              "${diff.toStringAsFixed(1)}% vs last month",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    });
  }
}