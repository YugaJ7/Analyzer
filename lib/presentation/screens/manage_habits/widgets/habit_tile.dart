import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../controllers/parameter_controller.dart';
import '../../../widgets/parameter_form_dialog.dart';
import 'confirm_delete_dialog.dart';

class HabitTile extends StatelessWidget {
  final dynamic param;
  final ParameterController controller;
  final int animDelay;

  const HabitTile({
    super.key,
    required this.param,
    required this.controller,
    required this.animDelay,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(param.color ?? 0xFF6C63FF);
    final isActive = param.isActive as bool;

    return Dismissible(
      key: ValueKey('dismiss_${param.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showConfirmDeleteDialog(context, param.name);
      },
      onDismissed: (_) {
        controller.deleteExistingParameter(param.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 24),
            SizedBox(height: 4),
            Text(
              AppStrings.deleteButton,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: isActive ? 0.08 : 0.04),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showEditDialog(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Color indicator + icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isActive ? 0.18 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.track_changes_rounded,
                      color: isActive ? color : color.withValues(alpha: 0.4),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          param.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        if (param.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            param.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Active toggle
                  GestureDetector(
                    onTap: () {
                      controller.updateExistingParameter(
                        param.id,
                        {'isActive': !isActive},
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 44,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.secondary
                            : Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        alignment: isActive
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
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
          parameter: param,
          onSave: (updated) async {
            Navigator.pop(context); // close sheet first
            await controller.updateExistingParameter(param.id, {
              'name': updated.name,
              'description': updated.description,
              'color': updated.color,
            });
            Get.snackbar(
              AppStrings.habitUpdatedTitle,
              '"${updated.name}" ${AppStrings.paramUpdatedMessage}',
              backgroundColor: AppColors.primary.withValues(alpha: 0.9),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ),
    );
  }
}
