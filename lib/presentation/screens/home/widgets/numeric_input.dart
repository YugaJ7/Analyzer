import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/entry_controller.dart';
import '../../../../core/theme/app_colors.dart';

class NumericInput extends StatefulWidget {
  final ParameterModel param;

  const NumericInput({super.key, required this.param});

  @override
  State<NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<NumericInput> {
  late final EntryController _entries = Get.find<EntryController>();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  late final List<Worker> _workers;

  @override
  void initState() {
    super.initState();
    _syncFromEntry();
    _focusNode.addListener(_onFocusChange);
    _workers = [
      ever(_entries.selectedDateEntries, (_) => _syncFromEntry()),
      // Typed text belongs to the previous day; release it so it saves there.
      ever(_entries.selectedDate, (_) => _focusNode.unfocus()),
    ];
  }

  @override
  void dispose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) return;
    _entries.flushPendingValues();
    _syncFromEntry();
  }

  /// Mirrors the stored value, but never under the user's cursor.
  void _syncFromEntry() {
    if (_focusNode.hasFocus) return;
    final text =
        _entries.selectedDateEntries[widget.param.id]?.value?.toString() ?? '';
    if (_controller.text != text) _controller.text = text;
  }

  void _onChanged(String value) {
    if (value.isEmpty) {
      _entries.setValueDeferred(widget.param.id, null);
      return;
    }
    final parsed = num.tryParse(value);
    if (parsed != null) _entries.setValueDeferred(widget.param.id, parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Divider(color: AppColors.divider, height: 1),
        SizedBox(height: 10),
        Text(
          AppStrings.hint,
          style: TextStyle(
            color: AppColors.secondaryText,
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
                color: AppColors.secondaryText,
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
                  fillColor: AppColors.inputFill,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.inputBorder),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: AppStrings.enterValue,
                  hintStyle: TextStyle(color: AppColors.inputHint, fontSize: 16),
                ),
                onChanged: _onChanged,
                onSubmitted: (_) => _focusNode.unfocus(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
