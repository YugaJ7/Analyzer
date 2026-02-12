import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:analyzer/core/utils/helper.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:analyzer/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ParameterController _paramController = Get.find<ParameterController>();
  final EntryController _entryController = Get.find<EntryController>();
  
  final RxInt _selectedIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (_selectedIndex.value) {
          case 0:
            return _buildHomeContent();
          case 1:
            return _buildAnalyticsPlaceholder();
          case 2:
            return _buildProfilePlaceholder();
          default:
            return _buildHomeContent();
        }
      }),
      bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E2749),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_rounded, 'Home', 0),
                    _buildNavItem(Icons.insights_rounded, 'Analytics', 1),
                    _buildNavItem(Icons.person_rounded, 'Profile', 2),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex.value == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Get.toNamed(AppRoutes.analytics);
        } else if (index == 2) {
          Get.toNamed(AppRoutes.profile);
        } else {
          _selectedIndex.value = index;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.5),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale();
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDateSelector(),
                  const SizedBox(height: 20),
                  _buildProgressCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Today\'s Parameters',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildParametersList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: -0.2, end: 0),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.wb_sunny_rounded,
            color: Color(0xFF6C63FF),
            size: 28,
          ),
        ).animate().scale(delay: 200.ms),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Obx(() {
      final selectedDate = _entryController.selectedDate.value;
      final isToday = _isSameDay(selectedDate, DateTime.now());
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2749),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                _entryController.changeSelectedDate(
                  selectedDate.subtract(const Duration(days: 1)),
                );
              },
              icon: const Icon(Icons.chevron_left, color: Colors.white),
            ),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Color(0xFF6C63FF),
                          surface: Color(0xFF1E2749),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  _entryController.changeSelectedDate(picked);
                }
              },
              child: Column(
                children: [
                  Text(
                    DateFormat('EEEE').format(selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: _isSameDay(selectedDate, DateTime.now())
                  ? null
                  : () {
                      _entryController.changeSelectedDate(
                        selectedDate.add(const Duration(days: 1)),
                      );
                    },
              icon: Icon(
                Icons.chevron_right,
                color: _isSameDay(selectedDate, DateTime.now())
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 100.ms);
    });
  }

  Widget _buildProgressCard() {
  return Obx(() {
    final selectedDate = _entryController.selectedDate.value;

    final visibleParams = _paramController.parameters.where((param) {
      final paramDate = DateTime(
        param.createdAt.year,
        param.createdAt.month,
        param.createdAt.day,
      );

      final selected = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );

      return !paramDate.isAfter(selected);
    }).toList();

    final totalParams = visibleParams.length;

    final completedParams =
        _entryController.selectedDateEntries.length;

    final completion = totalParams == 0
        ? 0
        : (completedParams / totalParams) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '$completedParams / $totalParams',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${completion.toStringAsFixed(0)}% Complete',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  });
}


  // Widget _buildParametersList() {
  //   return Obx(() {
  //     // No isLoading check needed since we're using real-time listener
      
  //     if (_paramController.parameters.isEmpty) {
  //       return SliverFillRemaining(
  //         child: Center(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               const Icon(
  //                 Icons.tune_rounded,
  //                 size: 80,
  //                 color: Color(0xFF6C63FF),
  //               ),
  //               const SizedBox(height: 16),
  //               const Text(
  //                 'No Parameters Yet',
  //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Add parameters to start tracking',
  //                 style: TextStyle(color: Colors.white.withOpacity(0.6)),
  //               ),
  //               const SizedBox(height: 24),
  //               ElevatedButton.icon(
  //                 onPressed: () => Get.toNamed(AppRoutes.parameterSetup),
  //                 icon: const Icon(Icons.add),
  //                 label: const Text('Add Parameters'),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xFF6C63FF),
  //                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     }

  //     return SliverPadding(
  //       padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
  //       sliver: SliverList(
  //         delegate: SliverChildBuilderDelegate(
  //           (context, index) {
  //             final param = _paramController.parameters[index];
  //             return _buildParameterEntryCard(param)
  //                 .animate()
  //                 .fadeIn(delay: Duration(milliseconds: 100 * index))
  //                 .slideX(begin: 0.2, end: 0);
  //           },
  //           childCount: _paramController.parameters.length,
  //         ),
  //       ),
  //     );
  //   });
  // }

  Widget _buildParametersList() {
  return Obx(() {
    final selectedDate = _entryController.selectedDate.value;

    final visibleParams = _paramController.parameters.where((param) {
      final paramDate = DateTime(
        param.createdAt.year,
        param.createdAt.month,
        param.createdAt.day,
      );

      final selected = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );

      return !paramDate.isAfter(selected);
    }).toList();

    if (visibleParams.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'No Parameters For This Day',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final param = visibleParams[index];
            return _buildParameterEntryCard(param)
                .animate()
                .fadeIn(
                    delay: Duration(milliseconds: 100 * index))
                .slideX(begin: 0.2, end: 0);
          },
          childCount: visibleParams.length,
        ),
      ),
    );
  });
}



  Widget _buildParameterEntryCard(ParameterModel param) {
  final isCompleted = _entryController.hasEntry(param.id);
  final currentValue =
      _entryController.selectedDateEntries[param.id]?.value;

  final color = getColorForParam(param.color);

  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: InkWell(
      onTap: () => _showEntryDialog(param),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    getIconForType(param.type),
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        param.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (param.description != null)
                        Text(
                          param.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Colors.white.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                ),

                /// ✅ AUTO TOGGLE CHECKBOX
                Checkbox(
                  value: isCompleted,
                  activeColor: const Color(0xFF4ECDC4),
                  onChanged: (_) async {
                    await _entryController.toggleEntry(
                        param.id, true);
                  },
                ),
              ],
            ),

            if (isCompleted && currentValue != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child:
                    _buildValueDisplay(param, currentValue),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}


  Widget _buildValueDisplay(ParameterModel param, dynamic value) {
    switch (param.type) {
      case ParameterType.scale:
        return Row(
          children: [
            const Icon(Icons.linear_scale_rounded, size: 16),
            const SizedBox(width: 8),
            Text(
              '$value / ${param.maxValue}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        );
      case ParameterType.checklist:
        if (value is List) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: value.map((item) => Chip(
              label: Text(item.toString(), style: const TextStyle(fontSize: 12)),
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
            )).toList(),
          );
        }
        return const Text('No items checked');
      case ParameterType.value:
        return Row(
          children: [
            const Icon(Icons.numbers_rounded, size: 16),
            const SizedBox(width: 8),
            Text(
              '$value ${param.unit ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        );
      case ParameterType.optionSelector:
        return Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 16),
            const SizedBox(width: 8),
            Text(
              value?.toString() ?? 'Not selected',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        );
    }
  }

  void _showEntryDialog(ParameterModel param) {
    final hasEntry = _entryController.hasEntry(param.id);
final currentValue = hasEntry
    ? _entryController.selectedDateEntries[param.id]?.value
    : null;

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1E2749),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: _EntryFormDialog(
          parameter: param,
          initialValue: currentValue,
          onSave: (value, notes) async {
            await _entryController.toggleEntry(param.id, value, notes: notes);

            Get.back();
          },
        ),
      ),
    );
  }

  Widget _buildAnalyticsPlaceholder() {
    return const Center(
      child: Text('Analytics Screen - Navigate using bottom nav'),
    );
  }

  Widget _buildProfilePlaceholder() {
    return const Center(
      child: Text('Profile Screen - Navigate using bottom nav'),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

}

// Entry Form Dialog
class _EntryFormDialog extends StatefulWidget {
  final ParameterModel parameter;
  final dynamic initialValue;
  final Function(dynamic, String?) onSave;

  const _EntryFormDialog({
    required this.parameter,
    this.initialValue,
    required this.onSave,
  });

  @override
  State<_EntryFormDialog> createState() => _EntryFormDialogState();
}

class _EntryFormDialogState extends State<_EntryFormDialog> {
  late dynamic currentValue;
  late TextEditingController notesController;
  late TextEditingController valueController;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController();
    valueController = TextEditingController();
    
    switch (widget.parameter.type) {
      case ParameterType.scale:
        currentValue = widget.initialValue ?? widget.parameter.minValue ?? 1;
        break;
      case ParameterType.checklist:
        currentValue = widget.initialValue ?? <String>[];
        break;
      case ParameterType.value:
        currentValue = widget.initialValue ?? 0;
        valueController.text = currentValue?.toString() ?? '0';
        break;
      case ParameterType.optionSelector:
        currentValue = widget.initialValue;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.parameter.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.parameter.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.parameter.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildInputWidget(),
          const SizedBox(height: 20),
          TextField(
            controller: notesController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Notes (Optional)',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              filled: true,
              fillColor: const Color(0xFF0A0E27),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
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
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      currentValue,
                      notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputWidget() {
    switch (widget.parameter.type) {
      case ParameterType.scale:
        return _buildScaleInput();
      case ParameterType.checklist:
        return _buildChecklistInput();
      case ParameterType.value:
        return _buildValueInput();
      case ParameterType.optionSelector:
        return _buildOptionSelectorInput();
    }
  }

  Widget _buildScaleInput() {
    final min = widget.parameter.minValue ?? 1;
    final max = widget.parameter.maxValue ?? 10;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Value: $currentValue',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Text('$min - $max',
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF6C63FF),
            inactiveTrackColor: const Color(0xFF6C63FF).withOpacity(0.2),
            thumbColor: const Color(0xFF6C63FF),
            overlayColor: const Color(0xFF6C63FF).withOpacity(0.2),
            trackHeight: 8,
          ),
          child: Slider(
            value: currentValue.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (value) {
              setState(() => currentValue = value.round());
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            (max - min) ~/ ((max - min) > 10 ? 2 : 1) + 1,
            (index) {
              int value = min + (index * ((max - min) > 10 ? 2 : 1));
              if (value <= max) {
                return Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistInput() {
    final items = widget.parameter.checklistItems ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        final isChecked = (currentValue as List<String>).contains(item);
        return CheckboxListTile(
          title: Text(item),
          value: isChecked,
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                (currentValue as List<String>).add(item);
              } else {
                (currentValue as List<String>).remove(item);
              }
            });
          },
          activeColor: const Color(0xFF6C63FF),
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildValueInput() {
    return TextField(
      controller: valueController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 18),
      onChanged: (value) {
        currentValue = double.tryParse(value) ?? 0;
      },
      decoration: InputDecoration(
        labelText: 'Enter value',
        suffix: Text(
          widget.parameter.unit ?? '',
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: const Color(0xFF0A0E27),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildOptionSelectorInput() {
    final options = widget.parameter.options ?? [];
    return Column(
      children: options.map((option) {
        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: currentValue,
          onChanged: (value) {
            setState(() => currentValue = value);
          },
          activeColor: const Color(0xFF6C63FF),
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    valueController.dispose();
    super.dispose();
  }
}
