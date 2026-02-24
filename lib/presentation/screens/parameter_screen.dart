import 'package:analyzer/core/routes/app_routes.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/parameter_controller.dart';
import '../../core/routes/app_background.dart';
import '../widgets/empty_state.dart';
import '../widgets/parameter_card.dart';
import '../widgets/parameter_form_dialog.dart';

class ParameterSetupScreen extends GetView<ParameterController> {
  const ParameterSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Parameters'),
        automaticallyImplyLeading: false,
        actions: [
          Obx(
            () => controller.parameters.isNotEmpty
                ? TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: AppBackground(
        colors: [
          AppColors.background,
          AppColors.surface,
          AppColors.primary.withValues(alpha: 0.1),
        ],
        child: SafeArea(
          child: Obx(() {
            if (controller.parameters.isEmpty) {
              return const EmptyStateWidget(
                title: "No parameters added yet.",
                message:
                    "Create your first parameter to start tracking your progress",
                icon: Icons.tune_rounded,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.parameters.length,
              itemBuilder: (context, index) {
                final param = controller.parameters[index];
                return Container(
                  key: ValueKey(param.id),
                  child:
                      ParameterCard(
                            param: param,
                            index: index,
                            onDismissed: (direction) =>
                                controller.deleteExistingParameter(param.id),
                            onTap: () =>
                                _showEditParameterDialog(context, param),
                          )
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 100 * index))
                          .slideX(begin: 0.2, end: 0),
                );
              },
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddParameterDialog(context),
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add),
        label: const Text('Add Parameter'),
      ).animate().scale(delay: 500.ms),
    );
  }

  void _showAddParameterDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              checklistItems: param.checklistItems,
              options: param.options,
              unit: param.unit,
              valueType: param.valueType,
              icon: param.icon,
              color: param.color,
            );
            await controller.addNewParameter(paramWithOrder);
            Get.back();
            Get.snackbar(
              'Success',
              'Parameter added successfully',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ),
    );
  }

  void _showEditParameterDialog(BuildContext context, ParameterEntity param) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ParameterFormDialog(
          parameter: param,
          onSave: (updatedParam) async {
            final updates = <String, dynamic>{
              'name': updatedParam.name,
              'description': updatedParam.description,
              'type': updatedParam.type.toString().split('.').last,
              'color': updatedParam.color,
            };

            switch (updatedParam.type) {
              case ParameterType.checklist:
                updates['checklistItems'] = updatedParam.checklistItems;
                updates['minValue'] = FieldValue.delete();
                updates['maxValue'] = FieldValue.delete();
                updates['options'] = FieldValue.delete();
                updates['unit'] = FieldValue.delete();
                updates['valueType'] = FieldValue.delete();
                break;
              case ParameterType.optionSelector:
                updates['options'] = updatedParam.options;
                updates['minValue'] = FieldValue.delete();
                updates['maxValue'] = FieldValue.delete();
                updates['checklistItems'] = FieldValue.delete();
                updates['unit'] = FieldValue.delete();
                updates['valueType'] = FieldValue.delete();
                break;
              case ParameterType.value:
                updates['unit'] = updatedParam.unit;
                updates['valueType'] = updatedParam.valueType;
                updates['minValue'] = FieldValue.delete();
                updates['maxValue'] = FieldValue.delete();
                updates['checklistItems'] = FieldValue.delete();
                updates['options'] = FieldValue.delete();
                break;
            }

            await controller.updateExistingParameter(param.id, updates);
            Get.back();
            Get.snackbar(
              'Success',
              'Parameter updated successfully',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ),
    );
  }
}
