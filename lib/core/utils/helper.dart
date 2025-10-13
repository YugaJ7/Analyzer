import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:flutter/material.dart';

String getTypeLabel(ParameterType type) {
    switch (type) {
      case ParameterType.checklist:
        return 'Checklist';
      case ParameterType.scale:
        return 'Scale';
      case ParameterType.value:
        return 'Value Entry';
      case ParameterType.optionSelector:
        return 'Option Selector';
    }
  }

  Color getColorForParam(String? colorStr) {
    if (colorStr == null) return const Color(0xFF6C63FF);
    try {
      return Color(int.parse(colorStr));
    } catch (e) {
      return const Color(0xFF6C63FF);
    }
  }

  IconData getIconForType(ParameterType type) {
    switch (type) {
      case ParameterType.checklist:
        return Icons.checklist_rounded;
      case ParameterType.scale:
        return Icons.linear_scale_rounded;
      case ParameterType.value:
        return Icons.numbers_rounded;
      case ParameterType.optionSelector:
        return Icons.radio_button_checked_rounded;
    }
  }