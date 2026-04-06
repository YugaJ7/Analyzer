import 'package:analyzer/core/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class AnimatedSplashContent extends StatelessWidget {
  final bool isLocked;
  final VoidCallback onUnlock;

  const AnimatedSplashContent({super.key, 
    required this.isLocked,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        top: isLocked ? 0 : 100,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // LOGO
          Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 2000.ms,
                color: Colors.white.withValues(alpha: 0.3),
              )
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms),

          const SizedBox(height: 32),

          const Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 12),

          Text(
            AppStrings.appTagline,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 40),

          // 🔐 Unlock Button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: isLocked
                ? ElevatedButton(
                    onPressed: onUnlock,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(AppStrings.unlockButton),
                  )
                    .animate()
                    .fadeIn()
                    .slideY(begin: 1)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}