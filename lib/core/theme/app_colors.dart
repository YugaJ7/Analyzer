import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0E27);
  static const Color surface = Color(0xFF1E2749);
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  
  static const Color textPrimary = Colors.white;
  static final Color textSecondary = Colors.white.withValues(alpha: 0.5);
  static final Color textTertiary = Colors.white.withValues(alpha: 0.3);
  
  static final Color cardOverlay = surface.withValues(alpha: 0.5);
  static final Color borderColor = Colors.white.withValues(alpha: 0.1);
}