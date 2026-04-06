import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/core/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../controllers/entry_controller.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final entryController = Get.find<EntryController>();

    return Obx(() {
      final selectedDate = entryController.selectedDate.value;
      final isToday = isSameDay(selectedDate, DateTime.now());

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                entryController.changeSelectedDate(
                  selectedDate.subtract(const Duration(days: 1)),
                );
              },
              icon: const Icon(Icons.chevron_left, color: Colors.white),
            ),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Color(0xFF6C63FF),
                          surface: Color(0xFF1E2749),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  entryController.changeSelectedDate(picked);
                }
              },
              child: Column(
                children: [
                  Text(
                    DateFormat('EEEE').format(selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        AppStrings.todayBadge,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: isSameDay(selectedDate, DateTime.now())
                  ? null
                  : () {
                      entryController.changeSelectedDate(
                        selectedDate.add(const Duration(days: 1)),
                      );
                    },
              icon: Icon(
                Icons.chevron_right,
                color: isSameDay(selectedDate, DateTime.now())
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms);
    });
  }
}
