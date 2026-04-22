import 'package:analyzer/core/theme/app_colors.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/entry_controller.dart';

class OptionSelector extends StatelessWidget {
  final ParameterModel param;

  const OptionSelector({super.key, required this.param});

  @override
  Widget build(BuildContext context) {
    final entryController = Get.find<EntryController>();
    final selectedValue = entryController.selectedDateEntries[param.id]?.value;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: param.options!.map<Widget>((option) {
          final isSelected = selectedValue == option;

          return GestureDetector(
            onTap: () {
              if (isSelected) {
                entryController.toggleEntry(param.id, null);
              } else {
                entryController.toggleEntry(param.id, option);
              }
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.completedborder.withAlpha(100)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
