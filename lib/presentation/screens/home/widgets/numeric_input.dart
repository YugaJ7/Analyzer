import 'package:analyzer/data/models/parameter_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/entry_controller.dart';

class NumericInput extends StatefulWidget {
  final ParameterModel param;

  const NumericInput({super.key, required this.param});

  @override
  State<NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<NumericInput> {
  late FocusNode _focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entryController = Get.find<EntryController>();

    return Obx(() {
      final entry = entryController.selectedDateEntries[widget.param.id];
      final currentValue = entry?.value?.toString() ?? '';

      _controller.text = currentValue;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );

      return AnimatedBuilder(
        animation: _focusNode,
        builder: (context, child) {
          final bool isFocused = _focusNode.hasFocus;

          return Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.transparent,
              border: Border.all(
                strokeAlign: BorderSide.strokeAlignCenter,
                color: isFocused
                    ? const Color(0xFF6C63FF)
                    : Colors.white.withValues(alpha: 0.3),
                width: isFocused ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                IntrinsicWidth(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: "Enter value",
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                    onChanged: (value) {
                      final entryController = Get.find<EntryController>();
                      if (value.isEmpty) {
                        entryController.toggleEntry(widget.param.id, null);
                        return;
                      }
                      final parsed = num.tryParse(value);
                      if (parsed != null) {
                        entryController.toggleEntry(widget.param.id, parsed);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.param.unit ?? '',
                  style: const TextStyle(color: Colors.white38, fontSize: 16),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
