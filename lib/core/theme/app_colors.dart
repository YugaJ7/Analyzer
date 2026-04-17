import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161C27);
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4834DF);
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color completedText = Color(0xFF4ADE80);
  static const Color secondaryText = Color(0xFF8892A4);
  static const Color error = Color(0xFFFF6B6B);
  static const Color red = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CAF50);
  static const Color orange = Color(0xFFFFA726);
  static const Color blue = Color(0xFF42A5F5);
  static const Color completedborder = Color(0xFF1D9E75);
  static const Color completedsurface = Color(0xFF0D2A1E);

  static const Color textPrimary = Colors.white;
  static final Color textSecondary = Colors.white.withValues(alpha: 0.5);
  static final Color textTertiary = Colors.white.withValues(alpha: 0.3);

  static final Color cardOverlay = surface.withValues(alpha: 0.5);
  static final Color borderSubtle = Colors.white.withValues(alpha: 0.05);
  static final Color borderColorPrimary = const Color.fromARGB(255, 187, 130, 130).withValues(alpha: 0.1);
  static final Color borderColorSecondary = Colors.white.withValues(alpha: 0.06);

  static final List<Map<String, dynamic>> availableColors = [
    {'color': 0xFF6C63FF, 'name': 'Purple'},
    {'color': 0xFF4ECDC4, 'name': 'Teal'},
    {'color': 0xFFFF6B6B, 'name': 'Red'},
    {'color': 0xFF4CAF50, 'name': 'Green'},
    {'color': 0xFFFFA726, 'name': 'Orange'},
    {'color': 0xFF42A5F5, 'name': 'Blue'},
  ];

  static const List<Color> heatColors = [
    Color(0xFF1A2340), // 0%  — near-empty
    Color(0xFF2A4858), // 1-25%
    Color(0xFF2E7D6E), // 25-50%
    Color(0xFF3EB489), // 50-75%
    Color(0xFF4ECDC4), // 75-100%
  ];
  static const Color emptyColor = Color(0xFF151B36);

  static const List<Color> medalColors = [
    Color(0xFFFFD700),
    Color(0xFFC0C0C0),
    Color(0xFFCD7F32),
  ];
}