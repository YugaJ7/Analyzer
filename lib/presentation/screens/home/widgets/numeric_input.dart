import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Divider(color: Color(0xFF2A2F3A), height: 1),
              SizedBox(height: 10),
              Text(
                AppStrings.enterValue,
                style: TextStyle(
                  color: Color(0xFF8892A4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    widget.param.unit ?? '',
                    style: TextStyle(
                      color: Color(0xFF8892A4),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        fillColor: Color(0xFF30302E),
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4E4E4A)),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4E4E4A)),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4E4E4A)),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF4E4E4A)),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: AppStrings.enterValue,
                        hintStyle: TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 16,
                        ),
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
                ],
              ),
            ],
          );
        },
      );
    });
  }
}
