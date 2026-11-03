import 'package:analyzer/core/utils/helper.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:analyzer/domain/entities/entry_entity.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:analyzer/presentation/controllers/streak_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../controllers/entry_controller.dart';
import 'numeric_input.dart';
import 'option_selector.dart';

class ParameterEntryCard extends StatefulWidget {
  final ParameterModel param;

  const ParameterEntryCard({super.key, required this.param});

  @override
  State<ParameterEntryCard> createState() => _ParameterEntryCardState();
}

class _ParameterEntryCardState extends State<ParameterEntryCard> {
  final EntryController _entries = Get.find<EntryController>();
  late final Worker _entryWorker;
  late EntryEntity? _entry;

  ParameterModel get param => widget.param;

  @override
  void initState() {
    super.initState();
    _entry = _entries.selectedDateEntries[param.id];
    // An Obx here would rebuild every card on any entry change, since reading
    // one RxMap key subscribes to the whole map.
    _entryWorker = ever(
      _entries.selectedDateEntries,
      (_) => _onEntriesChanged(),
    );
  }

  @override
  void didUpdateWidget(ParameterEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.param.id != param.id) {
      _entry = _entries.selectedDateEntries[param.id];
    }
  }

  @override
  void dispose() {
    _entryWorker.dispose();
    super.dispose();
  }

  void _onEntriesChanged() {
    final next = _entries.selectedDateEntries[param.id];
    if ((next == null) == (_entry == null) && next?.value == _entry?.value) {
      return;
    }
    setState(() => _entry = next);
  }

  @override
  Widget build(BuildContext context) {
    final color = getColorForParam(param.color);
    final entry = _entry;
    final isCompleted = entry != null;

    return GestureDetector(
      onTap: () {
        if (param.type == ParameterType.checklist) {
          _entries.toggleEntry(param.id, true);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.completedsurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? AppColors.completedborder
                : Colors.white.withValues(alpha: 0.06),
            width: isCompleted ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.completedborder
                          : Color(0xFF3A4356),
                      width: 2,
                    ),
                    color: isCompleted ? AppColors.completedborder : null,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        param.name,
                        style: TextStyle(
                          color: isCompleted
                              ? AppColors.completedText
                              : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (param.description != null)
                        Text(
                          "${param.description}",
                          style: TextStyle(
                            color: Color(0xFF8892A4),
                            fontSize: 12,
                          ),
                        ),
                    ],
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
                      final value = Get.find<StreakController>().getCurrent(
                        param.id,
                      );
                      return Text(
                        value.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
            if (param.type == ParameterType.value) NumericInput(param: param),
            if (param.type == ParameterType.optionSelector)
              OptionSelector(param: param, selectedValue: entry?.value),
          ],
        ),
      ),
    );
  }
}
