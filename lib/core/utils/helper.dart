import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:flutter/material.dart';

String getTypeLabel(ParameterType type) {
  switch (type) {
    case ParameterType.checklist:
      return 'Checklist';
    case ParameterType.value:
      return 'Value Entry';
    case ParameterType.optionSelector:
      return 'Option Selector';
  }
}

Color getColorForParam(int? colorValue) {
  if (colorValue == null) {
    return const Color(0xFF6C63FF);
  }
  try {
    return Color(colorValue);
  } catch (_) {
    return const Color(0xFF6C63FF);
  }
}

IconData getIconForType(ParameterType type) {
  switch (type) {
    case ParameterType.checklist:
      return Icons.checklist_rounded;
    case ParameterType.value:
      return Icons.numbers_rounded;
    case ParameterType.optionSelector:
      return Icons.radio_button_checked_rounded;
  }
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
