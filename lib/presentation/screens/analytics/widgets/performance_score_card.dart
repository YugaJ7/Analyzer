import 'dart:math';
import 'package:analyzer/core/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../controllers/analytics_controller.dart';

class PerformanceScoreCard extends StatelessWidget {
  const PerformanceScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Obx(() {
      final score = controller.performanceScore.value;
      final activeHabits = controller.totalActiveHabits.value;
      final currentStreak = controller.overallCurrentStreak.value;
      final bestStreak = controller.overallBestStreak.value;

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            /// Circular Score Ring
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background ring
                      CustomPaint(
                        size: const Size(160, 160),
                        painter: _RingPainter(
                          progress: 1.0,
                          strokeWidth: 12,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      // Progress ring
                      CustomPaint(
                        size: const Size(160, 160),
                        painter: _RingPainter(
                          progress: value,
                          strokeWidth: 12,
                          color: Colors.white,
                          useGradient: true,
                        ),
                      ),
                      // Score text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (value * 100).toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.score,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            /// Stat Chips Row
            Row(
              children: [
                _StatChip(
                  icon: Icons.track_changes_rounded,
                  label: AppStrings.active,
                  value: '$activeHabits',
                ),
                const SizedBox(width: 10),
                _StatChip(
                  icon: Icons.local_fire_department_rounded,
                  label: AppStrings.streak,
                  value: '$currentStreak',
                ),
                const SizedBox(width: 10),
                _StatChip(
                  icon: Icons.emoji_events_rounded,
                  label: AppStrings.best,
                  value: '$bestStreak',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final bool useGradient;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    this.useGradient = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (useGradient) {
      paint.shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: const [
          AppColors.secondary,
          Colors.white,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      paint.color = color;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}