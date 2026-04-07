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

// Maps Firebase Auth error codes to human-readable messages.
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
