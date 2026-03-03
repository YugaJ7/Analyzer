import 'package:analyzer/presentation/controllers/analytics_controller.dart';
import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:analyzer/presentation/screens/home/widgets/date_selector.dart';
import 'package:analyzer/presentation/screens/home/widgets/home_header.dart';
import 'package:analyzer/presentation/screens/home/widgets/home_skeleton.dart';
import 'package:analyzer/presentation/screens/home/widgets/parameter_list.dart';
import 'package:analyzer/presentation/screens/home/widgets/progress_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

    Future.microtask(() => _entryController.loadEntries());

    everAll([
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

      if (elapsed < 300) {
        await Future.delayed(Duration(milliseconds: 300 - elapsed));
      }

      if (mounted) {
        setState(() {
          _showSkeleton = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _showSkeleton ? const HomeSkeleton() : const _HomeTab(),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(),
                  SizedBox(height: 24),
                  DateSelector(),
                  SizedBox(height: 20),
                  ProgressCard(),
                  SizedBox(height: 24),
                  Text(
                    "Your Habits",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          ParameterList(),
        ],
      ),
    );
  }
}
