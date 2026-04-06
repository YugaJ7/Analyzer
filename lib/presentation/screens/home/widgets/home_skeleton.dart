import 'package:flutter/material.dart';
import 'package:analyzer/core/theme/app_colors.dart';
import '../../../widgets/shimmer_box.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  Widget _habitCardSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          // Checkbox circle
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          const SizedBox(width: 16),

          // Habit name
          Expanded(child: ShimmerBox(height: 18, width: 120)),

          const SizedBox(width: 16),

          // Flame + streak
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(width: 6),
              ShimmerBox(height: 18, width: 24),
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
                          ShimmerBox(height: 14, width: 80),
                          const SizedBox(height: 8),
                          ShimmerBox(height: 28, width: 180),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // DATE SELECTOR CARD
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShimmerBox(height: 14, width: 100),
                        const SizedBox(height: 12),
                        ShimmerBox(height: 20, width: 160),
                        const SizedBox(height: 12),
                        ShimmerBox(
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
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(height: 18, width: 150),
                        const SizedBox(height: 16),
                        ShimmerBox(
                          height: 12,
                          radius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 12),
                        ShimmerBox(height: 16, width: 120),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  //SECTION TITLE
                  ShimmerBox(height: 22, width: 140),

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
