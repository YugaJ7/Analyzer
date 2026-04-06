import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A shimmer placeholder box used in skeleton loading screens.
///
/// Replaces the duplicated `_shimmerBox` helper that previously existed in
/// both [HomeSkeleton] and the analytics [_AnalyticsSkeleton].
class ShimmerBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? radius;

  const ShimmerBox({
    super.key,
    required this.height,
    this.width,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          height: height,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: radius ?? BorderRadius.circular(12),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: Colors.white.withValues(alpha: 0.15),
        );
  }
}
