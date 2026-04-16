import 'package:analyzer/core/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../controllers/parameter_controller.dart';
import '../../widgets/parameter_form_dialog.dart';
import 'widgets/habit_empty_state.dart';
import 'widgets/habit_tile.dart';
import 'widgets/section_header.dart';

class ManageHabitsScreen extends StatelessWidget {
  const ManageHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ParameterController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          AppStrings.manageHabitsTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showAddDialog(context, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text(
                      AppStrings.manageAddButton,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final habits = controller.parameters;

        if (habits.isEmpty) {
          return const HabitEmptyState();
        }

        // Separate active and inactive
        final active = habits.where((h) => h.isActive).toList();
        final inactive = habits.where((h) => !h.isActive).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            if (active.isNotEmpty) ...[
              SectionHeader(
                title: AppStrings.activeHabitsSection,
                count: active.length,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 8),
              ...active.asMap().entries.map(
                (e) => HabitTile(
                  key: ValueKey(e.value.id),
                  param: e.value,
                  controller: controller,
                  animDelay: e.key * 50,
                ).animate().fadeIn(delay: Duration(milliseconds: e.key * 50)).slideX(begin: 0.1),
              ),
              const SizedBox(height: 20),
            ],
            if (inactive.isNotEmpty) ...[
              SectionHeader(
                title: AppStrings.inactiveHabitsSection,
                count: inactive.length,
                color: Colors.white38,
              ),
              const SizedBox(height: 8),
              ...inactive.asMap().entries.map(
                (e) => HabitTile(
                  key: ValueKey(e.value.id),
                  param: e.value,
                  controller: controller,
                  animDelay: (active.length + e.key) * 50,
                ).animate().fadeIn(delay: Duration(milliseconds: e.key * 50)).slideX(begin: 0.1),
              ),
            ],
          ],
        );
      }),
    );
  }

  void _showAddDialog(BuildContext context, ParameterController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ParameterFormDialog(
          onSave: (param) async {
            Navigator.pop(context); // close sheet after save
            await controller.addNewParameter(param);
            Get.snackbar(
              AppStrings.habitAddedTitle,
              '"${param.name}" ${AppStrings.paramAddedMessage}',
              backgroundColor: AppColors.secondary.withValues(alpha: 0.9),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ),
    );
  }
}
