import 'package:analyzer/core/theme/app_colors.dart';
import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/presentation/controllers/analytics_controller.dart';
import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:analyzer/presentation/screens/home/widgets/date_selector.dart';
import 'package:analyzer/presentation/screens/home/widgets/home_header.dart';
import 'package:analyzer/presentation/screens/home/widgets/parameter_list.dart';
import 'package:analyzer/presentation/screens/home/widgets/progress_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EntryController _entryController = Get.find<EntryController>();
  final ParameterController _paramController = Get.find<ParameterController>();
  final AnalyticsController _analyticsController =
      Get.find<AnalyticsController>();

  bool _showSkeleton = true;
  late DateTime _startTime;
  Worker? _worker;

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

    Future.microtask(() => _entryController.loadEntries());

    _worker = everAll([
      _paramController.isLoading,
      _analyticsController.isLoading,
    ], (_) => _checkLoadingComplete());
  }

  Future<void> _checkLoadingComplete() async {
    final stillLoading =
        _paramController.isLoading.value ||
        _analyticsController.isLoading.value;

    if (!stillLoading && _showSkeleton) {
      final elapsed = DateTime.now().difference(_startTime).inMilliseconds;

      if (elapsed < 700) {
        await Future.delayed(Duration(milliseconds: 700 - elapsed));
      }

      if (mounted) {
        setState(() {
          _showSkeleton = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: animation, child: child),
          );
        },

        child: _showSkeleton
            ? Skeletonizer(
                enabled: true,
                effect: ShimmerEffect(
                  baseColor: Colors.white.withOpacity(0.05),
                  highlightColor: Colors.white.withOpacity(0.1),
                  duration: const Duration(milliseconds: 1400),
                ),
                child: _HomeTab(),
              )
            : _HomeTab(),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(),
                  DateSelector(),
                  ProgressCard(),
                  Text(
                    AppStrings.yourHabits,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
            sliver: ParameterList(),
          ),
        ],
      ),
    );
  }
}
