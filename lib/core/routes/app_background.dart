import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final List<Color>? colors;
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ??
              [
                AppColors.background,
                AppColors.surface,
                AppColors.primary.withValues(alpha: 0.2),
              ],
        ),
      ),
      child: child,
    );
  }
}
