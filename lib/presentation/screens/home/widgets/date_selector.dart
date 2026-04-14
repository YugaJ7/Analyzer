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
        margin: EdgeInsets.only(top: 12, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                entryController.changeSelectedDate(
                  selectedDate.subtract(const Duration(days: 1)),
                );
              },
              icon: const Icon(Icons.chevron_left),
              color: AppColors.secondaryText,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: Get.context!,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark(),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    entryController.changeSelectedDate(picked);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('EEEE').format(selectedDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (isToday)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E4D3A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          AppStrings.todayBadge,
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF4ADE80),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: isToday
                  ? null
                  : () {
                      entryController.changeSelectedDate(
                        selectedDate.add(const Duration(days: 1)),
                      );
                    },
              icon: const Icon(Icons.chevron_right),
              color: isToday
                  ? Color(0xFF8892A4)
                  : Color(0xFF8892A4).withOpacity(0.8),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    });
  }
}
