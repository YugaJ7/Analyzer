import 'package:analyzer/core/theme/app_colors.dart';
import 'package:analyzer/data/models/parameter_model.dart';
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

String getGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) return "Good Morning 👋";
  if (hour < 17) return "Good Afternoon 👋";
  return "Good Evening 👋";
}

String mapAuthError(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No account found for this email.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'email-already-in-use':
      return 'This email is already registered.';
    case 'weak-password':
      return 'Password must be at least 6 characters with letters and numbers.';
    case 'network-request-failed':
      return 'No internet connection. Please check your network.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a moment and try again.';
    case 'user-disabled':
      return 'This account has been disabled. Contact support.';
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled.';
    case 'requires-recent-login':
      return 'Please log out and log back in before changing your password.';
    case 'invalid-credential':
      return 'Invalid credentials. Check your email and password.';
    default:
      return 'Authentication error. Please try again.';
  }
}

Color colorFromPercent(double percent) {
  if (percent <= 0) return AppColors.emptyColor;
  if (percent < 25) return AppColors.heatColors[1];
  if (percent < 50) return AppColors.heatColors[2];
  if (percent < 75) return AppColors.heatColors[3];
  return AppColors.heatColors[4];
}

ParameterModel fakeParam(
  String name, {
  ParameterType type = ParameterType.checklist,
}) {
  return ParameterModel(
    id: '-1',
    name: name,
    description: null,
    type: type,
    color: 1,
    createdAt: DateTime.now(),
    isActive: true, userId: '', 
    order: 1,
  );
}