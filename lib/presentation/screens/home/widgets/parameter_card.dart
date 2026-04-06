import 'package:analyzer/core/utils/helper.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:analyzer/presentation/controllers/streak_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../controllers/entry_controller.dart';
import 'numeric_input.dart';
import 'option_selector.dart';

class ParameterEntryCard extends StatelessWidget {
  final ParameterModel param;

  const ParameterEntryCard({super.key, required this.param});

  @override
  Widget build(BuildContext context) {
    final color = getColorForParam(param.color);
    final entryController = Get.find<EntryController>();

    return Obx(() {
      final entry = entryController.selectedDateEntries[param.id];
      final isCompleted = entry != null;

      return GestureDetector(
        onTap: () {
          if (param.type == ParameterType.checklist) {
            entryController.toggleEntry(param.id, true);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.primary
                              : Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        color: isCompleted
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        param.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: color,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Obx(() {
                          final value = Get.find<StreakController>().getCurrent(param.id);
                          return Text(
                            value.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                if (param.type == ParameterType.value)
                  NumericInput(param: param),
                if (param.type == ParameterType.optionSelector)
                  OptionSelector(param: param),
              ],
            ),
          ),
        ),
      );
    });
  }
}
