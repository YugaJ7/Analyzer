import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../controllers/parameter_controller.dart';
import '../../widgets/parameter_form_dialog.dart';

class ManageHabitsScreen extends StatelessWidget {
  const ManageHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ParameterController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E27),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Manage Habits',
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
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Add',
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Color(0xFF6C63FF),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No habits yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap "Add" to create your first habit',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // Separate active and inactive
        final active = habits.where((h) => h.isActive).toList();
        final inactive = habits.where((h) => !h.isActive).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            if (active.isNotEmpty) ...[
              _sectionHeader('Active Habits', active.length, const Color(0xFF4ECDC4)),
              const SizedBox(height: 8),
              ...active.asMap().entries.map(
                (e) => _HabitTile(
                  key: ValueKey(e.value.id),
                  param: e.value,
                  controller: controller,
                  animDelay: e.key * 50,
                ).animate().fadeIn(delay: Duration(milliseconds: e.key * 50)).slideX(begin: 0.1),
              ),
              const SizedBox(height: 20),
            ],
            if (inactive.isNotEmpty) ...[
              _sectionHeader('Inactive Habits', inactive.length, Colors.white38),
              const SizedBox(height: 8),
              ...inactive.asMap().entries.map(
                (e) => _HabitTile(
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

  Widget _sectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, ParameterController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E2749),
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
              'Habit Added',
              '"${param.name}" has been added',
              backgroundColor: const Color(0xFF4ECDC4).withValues(alpha: 0.9),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Habit Tile
// ─────────────────────────────────────────────
class _HabitTile extends StatelessWidget {
  final dynamic param;
  final ParameterController controller;
  final int animDelay;

  const _HabitTile({
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
        return await _confirmDelete(context, param.name);
      },
      onDismissed: (_) {
        controller.deleteExistingParameter(param.id);
        // Get.snackbar(
        //   'Habit Deleted',
        //   '"${param.name}" has been permanently deleted',
        //   backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.9),
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.BOTTOM,
        // );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6B6B), size: 24),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2749),
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
                            ? const Color(0xFF4ECDC4)
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
      backgroundColor: const Color(0xFF1E2749),
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
              'Habit Updated',
              '"${updated.name}" has been updated',
              backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.9),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E2749),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            title: const Text(
              'Delete Habit?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              '"$name" will be permanently deleted. This cannot be undone.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
