import 'package:analyzer/core/utils/app_strings.dart';
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
        if (!param.isActive) return false;

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
        margin: EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Color(0xFF1A4A7A), Color(0xFF0F6E56)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isToday ? AppStrings.todayProgress : AppStrings.progress,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(.9),
                  ),
                ),
                Text(
                  '$completedParams/$totalParams',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${completion.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: completion / 100),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$completedParams of $totalParams habits completed',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
      );
    });
  }
}
