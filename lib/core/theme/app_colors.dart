import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0E27);
  static const Color surface = Color(0xFF1E2749);
  static const Color primary = Color(0xFF6C63FF);
  /// Darker primary used as the end stop of gradient fills.
  static const Color primaryDark = Color(0xFF4834DF);
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color error = Color(0xFFFF6B6B);
  /// Alias kept for semantic clarity — maps to [error].
  static const Color red = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CAF50);
  static const Color orange = Color(0xFFFFA726);
  static const Color blue = Color(0xFF42A5F5);

  static const Color textPrimary = Colors.white;
  static final Color textSecondary = Colors.white.withValues(alpha: 0.5);
  static final Color textTertiary = Colors.white.withValues(alpha: 0.3);

  static final Color cardOverlay = surface.withValues(alpha: 0.5);
  static final Color borderSubtle = Colors.white.withValues(alpha: 0.05);
  static final Color borderColorPrimary = Colors.white.withValues(alpha: 0.1);
  static final Color borderColorSecondary = Colors.white.withValues(alpha: 0.06);

  static final List<Map<String, dynamic>> availableColors = [
    {'color': 0xFF6C63FF, 'name': 'Purple'},
    {'color': 0xFF4ECDC4, 'name': 'Teal'},
    {'color': 0xFFFF6B6B, 'name': 'Red'},
    {'color': 0xFF4CAF50, 'name': 'Green'},
    {'color': 0xFFFFA726, 'name': 'Orange'},
    {'color': 0xFF42A5F5, 'name': 'Blue'},
  ];
}