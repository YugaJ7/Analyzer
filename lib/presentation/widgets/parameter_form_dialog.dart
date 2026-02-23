import 'package:analyzer/core/utils/helper.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'custom_text_field.dart';
import 'custom_button.dart';

class ParameterFormDialog extends StatefulWidget {
  final ParameterEntity? parameter;
  final Function(ParameterEntity) onSave;

  const ParameterFormDialog({super.key, this.parameter, required this.onSave});

  @override
  State<ParameterFormDialog> createState() => _ParameterFormDialogState();
}

class _ParameterFormDialogState extends State<ParameterFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late ParameterType selectedType;
  late List<String> checklistItems;
  late List<String> options;
  late TextEditingController unitController;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.parameter?.name ?? '');
    descriptionController = TextEditingController(text: widget.parameter?.description ?? '');
    selectedType = widget.parameter?.type ?? ParameterType.checklist;
    checklistItems = widget.parameter?.checklistItems ?? [''];
    options = widget.parameter?.options ?? [''];
    unitController = TextEditingController(text: widget.parameter?.unit ?? '');
    selectedColor = Color(widget.parameter?.color ?? 0xFF6C63FF);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.parameter == null ? 'Add Parameter' : 'Edit Parameter',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: nameController,
                label: "Name",
                hint: "e.g. Did you exercise today?",
                fillColor: AppColors.background,
                focusBorderColor: AppColors.background,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descriptionController,
                label: "Description (Optional)",
                hint: "Brief description",
                fillColor: AppColors.background,
                focusBorderColor: AppColors.background,
              ),
              SizedBox(height: 20),
              const Text(
                'Parameter Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildTypeSelector(),
              const SizedBox(height: 20),
              _buildTypeSpecificFields(),
              const SizedBox(height: 20),
              const Text(
                'Color Theme',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildColorSelector(),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: "Save",
                      background: AppColors.primary,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // --- Proceed to save ---
                          final currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser == null) {
                            Get.snackbar(
                              'Error',
                              'You must be signed in to save parameters',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          final cleanedChecklist = checklistItems
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();
                          final cleanedOptions = options
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();
                          final trimmedUnit = unitController.text.trim();
                          final parameter = ParameterEntity(
                            id: widget.parameter?.id ?? '',
                            userId: currentUser.uid,
                            createdAt: DateTime.now(),

                            name: nameController.text.trim(),
                            description:
                                descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            type: selectedType,
                            order: widget.parameter?.order ?? 0,
                            checklistItems:
                                selectedType == ParameterType.checklist
                                ? (cleanedChecklist.isEmpty
                                    ? null
                                    : cleanedChecklist)
                                : null,
                            options:
                                selectedType == ParameterType.optionSelector
                                ? (cleanedOptions.isEmpty ? null : cleanedOptions)
                                : null,
                            unit: selectedType == ParameterType.value
                                ? (trimmedUnit.isEmpty ? null : trimmedUnit)
                                : null,
                            valueType: selectedType == ParameterType.value
                                ? 'number'
                                : null,
                            color: selectedColor.toARGB32(),
                          );
                          await widget.onSave(parameter);
                          Get.back();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ParameterType.values.map((type) {
        final isSelected = selectedType == type;
        return ChoiceChip(
          label: Text(getTypeLabel(type)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => selectedType = type);
            }
          },
          selectedColor: const Color(0xFF6C63FF),
          backgroundColor: const Color(0xFF0A0E27),
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeSpecificFields() {
    switch (selectedType) {
      case ParameterType.checklist:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Checklist Items',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...checklistItems.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value,
                        onChanged: (val) => checklistItems[entry.key] = val,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Item ${entry.key + 1}',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF0A0E27),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            height: 0.8,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.warning,
                      ),
                      onPressed: () {
                        if (checklistItems.length > 1) {
                          setState(() => checklistItems.removeAt(entry.key));
                        }
                      },
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() => checklistItems.add('')),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        );

      case ParameterType.optionSelector:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Options',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...options.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value,
                        onChanged: (val) => options[entry.key] = val,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Option ${entry.key + 1}',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF0A0E27),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            height: 0.8,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.warning,
                      ),
                      onPressed: () {
                        if (options.length > 1) {
                          setState(() => options.removeAt(entry.key));
                        }
                      },
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() => options.add('')),
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),
          ],
        );

      case ParameterType.value:
        return CustomTextField(
          controller: unitController,
          label: 'Unit (Optional)',
          hint: 'e.g., liters, km, hours',
          fillColor: AppColors.background,
          focusBorderColor: AppColors.background,
        );
    }
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 18,
      runSpacing: 12,
      children: AppColors.availableColors.map((colorData) {
        final color = Color(colorData['color'] as int);
        final isSelected = selectedColor.toARGB32() == color.toARGB32();
        return GestureDetector(
          onTap: () {
            setState(() => selectedColor = color);
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    unitController.dispose();
    super.dispose();
  }
}
