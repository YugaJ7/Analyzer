import 'package:analyzer/core/theme/app_colors.dart';
import 'package:analyzer/core/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnalyticsHeader extends StatelessWidget {
  const AnalyticsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.analyticsTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ).animate().fadeIn().slideX(begin: -0.15),
        const SizedBox(height: 2),
        Text(
          AppStrings.analyticsSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 100.ms),
      ],
    );
  }
}