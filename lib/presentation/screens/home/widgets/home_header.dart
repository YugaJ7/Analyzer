import 'package:analyzer/core/theme/app_colors.dart';
import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/core/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getGreeting(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              AppStrings.homeWelcome,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.15, end: 0, curve: Curves.easeOutCubic);
  }
}
