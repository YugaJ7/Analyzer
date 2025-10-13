import 'package:analyzer/core/utils/helper.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../domain/entities/parameter_entity.dart';

class ParameterCard extends StatelessWidget {
  final ParameterEntity param;
  final int index;
  final void Function (DismissDirection) onDismissed;
  final void Function() onTap;

  const ParameterCard({super.key, required this.param, required this.index, required this.onDismissed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon = getIconForType(param.type);
    Color color = getColorForParam(param.color);
    return Dismissible(
      key: ValueKey(param.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: ShapeDecoration(
          color: AppColors.warning.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: onDismissed,
      child: GestureDetector(
        onTap:onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          shadowColor: AppColors.surface,
          color: AppColors.cardOverlay,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            title: Text(
              param.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              getTypeLabel(param.type),
              style: TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
