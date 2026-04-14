import 'package:analyzer/core/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../controllers/analytics_controller.dart';

class TopHabitsCard extends StatelessWidget {
  const TopHabitsCard({super.key});

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Obx(() {
      final habits = controller.topHabits;

      if (habits.isEmpty) {
        return const SizedBox.shrink();
      }

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
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFFFD700),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    AppStrings.topPerformers,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...List.generate(habits.length, (index) {
                final habit = habits[index];
                final medal = index < _medals.length ? _medals[index] : '•';
                final accentColor = index < AppColors.medalColors.length 
                    ? AppColors.medalColors[index] 
                    : Colors.white38;
        
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      // Rank
                      SizedBox(
                        width: 36,
                        child: Text(
                          medal,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Habit name
                      Expanded(
                        child: Text(
                          habit,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Rank indicator bar
                      Container(
                        height: 6,
                        width: 60 - (index * 15.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withValues(alpha: 0.4),
                              accentColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}