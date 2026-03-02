import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  Widget _box(double height, {double? width}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.2),
        );
  }

  Widget _card() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2749),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(20, width: 150),
          const SizedBox(height: 16),
          _box(12),
          const SizedBox(height: 8),
          _box(12, width: 200),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _box(40, width: 200),
            const SizedBox(height: 24),
            _box(80),
            const SizedBox(height: 24),
            _card(),
            _card(),
            _card(),
          ],
        ),
      ),
    );
  }
}