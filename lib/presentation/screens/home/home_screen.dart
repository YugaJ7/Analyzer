import 'dart:developer';

import 'package:analyzer/core/theme/app_colors.dart';
import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/data/services/widget_action_sync_service.dart';
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final EntryController _entryController = Get.find<EntryController>();
  final ParameterController _paramController = Get.find<ParameterController>();

  bool _showSkeleton = true;
  late DateTime _startTime;
  Worker? _worker;
  bool _widgetSyncReady = false;
  Stopwatch? _loadStopwatch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _startTime = DateTime.now();

    Future.microtask(_loadAndProcessWidgetActions);

    _worker = everAll([
      _paramController.isLoading,
      _entryController.isLoading,
    ], (_) => _checkLoadingComplete());
  }

  Future<void> _loadAndProcessWidgetActions() async {
    if (mounted) {
      setState(() {
        _showSkeleton = true;
        _widgetSyncReady = false;
        _startTime = DateTime.now();
      });
    }

    _loadStopwatch = Stopwatch()..start();
    log('home: startup sync begin', name: 'PERF');

    final entriesStopwatch = Stopwatch()..start();
    await _entryController.loadEntries(syncWidget: false);
    log(
      'home: entries ready in ${entriesStopwatch.elapsedMilliseconds}ms',
      name: 'PERF',
    );

    final widgetActionStopwatch = Stopwatch()..start();
    await WidgetActionSyncService.processPendingActions();
    log(
      'home: widget actions processed in ${widgetActionStopwatch.elapsedMilliseconds}ms',
      name: 'PERF',
    );

    if (mounted) {
      setState(() {
        _widgetSyncReady = true;
      });
    }

    await _checkLoadingComplete();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.microtask(_loadAndProcessWidgetActions);
    }
  }

  Future<void> _checkLoadingComplete() async {
    final stillLoading =
        _paramController.isLoading.value ||
        _entryController.isLoading.value ||
        WidgetActionSyncService.isStartupSyncing.value ||
        !_widgetSyncReady;

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

      if (_loadStopwatch != null) {
        log(
          'home: content visible in ${_loadStopwatch!.elapsedMilliseconds}ms',
          name: 'PERF',
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
                  baseColor: Colors.white.withValues(alpha: 0.05),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
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
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
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
