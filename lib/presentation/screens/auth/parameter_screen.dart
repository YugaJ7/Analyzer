import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/parameter_controller.dart';
import '../../widgets/parameter_form_dialog.dart';
import '../manage_habits/widgets/habit_empty_state.dart';
import '../manage_habits/widgets/habit_tile.dart';

class ParameterSetupScreen extends GetView<ParameterController> {
  const ParameterSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          AppStrings.paramSetupTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Finishing setup is the primary action, so it takes the prominent
          // slot; adding moves to the FAB to keep the app bar uncluttered.
          Obx(
            () => controller.parameters.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilledButton.icon(
                      onPressed: () => Get.offAllNamed(AppRoutes.home),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text(
                        AppStrings.paramSetupDoneButton,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        tooltip: AppStrings.addParameterButton,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: Obx(() {
        final habits = controller.parameters;

        if (habits.isEmpty) {
          return const HabitEmptyState(
            subtitle: AppStrings.paramSetupEmptyHint,
          );
        }

        return ListView.builder(
          // Bottom inset keeps the last habit clear of the FAB.
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final param = habits[index];
            return HabitTile(
                  key: ValueKey(param.id),
                  param: param,
                  controller: controller,
                  animDelay: index * 50,
                )
                .animate()
                .fadeIn(delay: Duration(milliseconds: index * 50))
                .slideX(begin: 0.1);
          },
        );
      }),
    );
  }

  void _showAddDialog(BuildContext context) {
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
            final paramWithOrder = ParameterEntity(
              id: param.id,
              userId: param.userId,
              createdAt: param.createdAt,
              name: param.name,
              description: param.description,
              type: param.type,
              order: controller.parameters.length,
              isActive: param.isActive,
              options: param.options,
              unit: param.unit,
              icon: param.icon,
              color: param.color,
            );
            if (!await controller.addNewParameter(paramWithOrder)) return;
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
