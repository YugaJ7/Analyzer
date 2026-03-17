import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/analytics_controller.dart';

class WeeklySummaryCard extends StatelessWidget {
  const WeeklySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Obx(() {
      final completed = controller.weeklyCompleted.value;
      final total = controller.weeklyTotal.value;
      final percentage = total == 0 ? 0.0 : (completed / total);
      final percentText = (percentage * 100).toStringAsFixed(0);

      String motivation;
      if (percentage >= 0.9) {
        motivation = 'Incredible week! 🔥';
      } else if (percentage >= 0.7) {
        motivation = 'Great consistency! 💪';
      } else if (percentage >= 0.5) {
        motivation = 'Good effort, keep going!';
      } else if (percentage > 0) {
        motivation = 'Room to improve 📈';
      } else {
        motivation = 'Start building habits!';
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2749),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            // Progress Ring
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percentage),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(72, 72),
                        painter: _MiniRingPainter(
                          progress: value,
                          bgColor: Colors.white.withValues(alpha: 0.08),
                          fgColor: const Color(0xFF4ECDC4),
                        ),
                      ),
                      Text(
                        '$percentText%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 20),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: const Color(0xFF4ECDC4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$completed / $total completed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      motivation,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4ECDC4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  final Color bgColor;
  final Color fgColor;

  _MiniRingPainter({
    required this.progress,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    // Background
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = bgColor,
    );

    // Foreground
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = fgColor,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}