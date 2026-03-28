import 'package:analyzer/core/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../controllers/entry_controller.dart';
import '../../../controllers/parameter_controller.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final entryController = Get.find<EntryController>();
    final paramController = Get.find<ParameterController>();

    return Obx(() {
      final selectedDate = entryController.selectedDate.value;
      final isToday = isSameDay(selectedDate, DateTime.now());

      final visibleParams = paramController.parameters.where((param) {
        if (!param.isActive) return false;   // only count active habits
        final paramDate = DateTime(
          param.createdAt.year,
          param.createdAt.month,
          param.createdAt.day,
        );

        final selected = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );

        return !paramDate.isAfter(selected);
      }).toList();

      final totalParams = visibleParams.length;

      final completedParams = entryController.selectedDateEntries.length;

      final completion = totalParams == 0
          ? 0
          : (completedParams / totalParams) * 100;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isToday ? 'Today\'s Progress' : 'Progress',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$completedParams / $totalParams',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: completion / 100),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${completion.toStringAsFixed(0)}% Complete',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ).animate().fadeIn(),
          ],
        ),
      );
    });
  }
}
