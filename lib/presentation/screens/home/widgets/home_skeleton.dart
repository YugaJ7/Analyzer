import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  Widget _shimmerBox({
    required double height,
    double? width,
    BorderRadius? radius,
  }) {
    return Container(
          height: height,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: radius ?? BorderRadius.circular(12),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.15));
  }

  Widget _habitCardSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2749),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Checkbox circle
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          const SizedBox(width: 16),

          // Habit name
          Expanded(child: _shimmerBox(height: 18, width: 120)),

          const SizedBox(width: 16),

          // Flame + streak
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              const SizedBox(width: 6),
              _shimmerBox(height: 18, width: 24),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerBox(height: 14, width: 80),
                          const SizedBox(height: 8),
                          _shimmerBox(height: 28, width: 180),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // DATE SELECTOR CARD
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2749),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _shimmerBox(height: 14, width: 100),
                        const SizedBox(height: 12),
                        _shimmerBox(height: 20, width: 160),
                        const SizedBox(height: 12),
                        _shimmerBox(
                          height: 22,
                          width: 60,
                          radius: BorderRadius.circular(12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // PROGRESS CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(height: 18, width: 150),
                        const SizedBox(height: 16),
                        _shimmerBox(
                          height: 12,
                          radius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 12),
                        _shimmerBox(height: 16, width: 120),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  //SECTION TITLE
                  _shimmerBox(height: 22, width: 140),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // HABIT LIST
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _habitCardSkeleton(),
                childCount: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
