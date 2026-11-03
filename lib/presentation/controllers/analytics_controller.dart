import 'package:analyzer/core/utils/app_logger.dart';
import 'package:analyzer/data/cache/analytics_cache_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/entry_entity.dart';
import '../../domain/repositories/entry_repository.dart';
import '../../domain/services/streak_calculator.dart';
import 'parameter_controller.dart';

class AnalyticsController extends GetxController {
  final EntryRepository entryRepository;
  final ParameterController parameterController;
  final AnalyticsCacheService cacheService;

  final DateTime Function() _today;
  final String Function() _userId;

  AnalyticsController({
    required this.entryRepository,
    required this.parameterController,
    required this.cacheService,
    DateTime Function()? today,
    String Function()? userId,
  }) : _today = today ?? AppDateUtils.today,
       _userId = userId ?? (() => FirebaseAuth.instance.currentUser!.uid);

  static const _windowDays = 365;

  final RxBool isLoading = false.obs;

  final Map<DateTime, List<EntryEntity>> _history = {};
  Map<DateTime, List<EntryEntity>> get history => _history;

  final RxDouble performanceScore = 0.0.obs;
  final RxDouble overallCompletionRate = 0.0.obs;
  final RxInt totalActiveHabits = 0.obs;

  final RxInt overallCurrentStreak = 0.obs;
  final RxInt overallBestStreak = 0.obs;

  final RxList<double> last7DaysTrend = <double>[].obs;
  final RxList<double> last30DaysTrend = <double>[].obs;

  final RxMap<int, double> weekdayBreakdown = <int, double>{}.obs;
  final RxMap<int, double> currentWeekBreakdown = <int, double>{}.obs;

  final RxInt weeklyCompleted = 0.obs;
  final RxInt weeklyTotal = 0.obs;

  final RxDouble monthComparison = 0.0.obs;
  final RxList<String> topHabits = <String>[].obs;
  final RxMap<DateTime, double> heatmapData = <DateTime, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    loadAnalytics();

    // Habits can arrive after entries, and removing the last one must still
    // clear the stats, so recompute on every change even with no history.
    ever(parameterController.parameters, (_) => _computeAnalytics());
  }

  Future<void> loadAnalytics() async {
    isLoading.value = true;
    try {
      final data = await entryRepository.getEntriesForLastNDays(
        _userId(),
        _windowDays,
      );

      _history
        ..clear()
        ..addAll(data);

      _computeAnalytics();
    } catch (error, stackTrace) {
      // Keep whatever is on screen; a later load or entry change recomputes.
      AppLogger.error(
        'Analytics load failed',
        name: 'AnalyticsController',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateFromEntryChange(String parameterId, DateTime date, bool isAdded) {
    final normalized = DateTime(date.year, date.month, date.day);

    _history.putIfAbsent(normalized, () => []);

    if (isAdded) {
      _history[normalized]!.add(
        EntryEntity(
          id: "",
          userId: "",
          parameterId: parameterId,
          date: normalized,
          value: true,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      _history[normalized]!.removeWhere((e) => e.parameterId == parameterId);
    }

    cacheService.save(_history);
    _computeAnalytics();
  }

  void removeHabitEntries(String parameterId) {
    bool changed = false;

    _history.forEach((date, entries) {
      final before = entries.length;
      entries.removeWhere((e) => e.parameterId == parameterId);
      if (entries.length != before) changed = true;
    });

    _history.removeWhere((_, entries) => entries.isEmpty);

    if (changed) {
      cacheService.save(_history);
      _computeAnalytics();
    }
  }

  /// Builds every stat locally and publishes each observable once; writing
  /// into them per day fired hundreds of rebuilds per recompute.
  void _computeAnalytics() {
    final activeHabits = parameterController.parameters
        .where((p) => p.isActive)
        .toList();

    totalActiveHabits.value = activeHabits.length;
    if (activeHabits.isEmpty) {
      _resetStats();
      return;
    }

    // A habit only counts toward days on or after the day it was created.
    final startById = {
      for (final habit in activeHabits)
        habit.id: AppDateUtils.dateOnly(habit.createdAt),
    };
    final nameById = {for (final habit in activeHabits) habit.id: habit.name};

    final startOfToday = AppDateUtils.dateOnly(_today());
    final mondayOfThisWeek = AppDateUtils.addDays(
      startOfToday,
      -(startOfToday.weekday - 1),
    );

    var totalCompleted = 0, totalPossible = 0;
    var weekCompleted = 0, weekPossible = 0;
    var monthCompleted = 0, monthPossible = 0;
    final heatmap = <DateTime, double>{};
    final trend30 = <double>[];
    final weekdayRates = <int, List<double>>{};
    final currentWeek = {for (var day = 1; day <= 7; day++) day: 0.0};
    final completionsById = <String, int>{};
    final activeDays = <DateTime>[];

    for (var i = 0; i < _windowDays; i++) {
      final date = AppDateUtils.addDays(startOfToday, -i);
      final possible = startById.values
          .where((start) => !start.isAfter(date))
          .length;

      final completedIds = <String>{};
      for (final entry in _history[date] ?? const <EntryEntity>[]) {
        final start = startById[entry.parameterId];
        if (start != null && !start.isAfter(date)) {
          completedIds.add(entry.parameterId);
        }
      }
      final completed = completedIds.length;
      final rate = _percent(completed, possible);

      for (final id in completedIds) {
        completionsById.update(id, (count) => count + 1, ifAbsent: () => 1);
      }
      if (completed > 0) activeDays.add(date);
      heatmap[date] = rate;

      if (i < 30) {
        trend30.add(rate);
        monthCompleted += completed;
        monthPossible += possible;
      }
      if (!date.isBefore(mondayOfThisWeek)) {
        currentWeek[date.weekday] = rate;
        weekCompleted += completed;
        weekPossible += possible;
      }
      // Days before any habit existed would drag every average toward zero.
      if (possible > 0) {
        weekdayRates.putIfAbsent(date.weekday, () => []).add(rate);
        totalCompleted += completed;
        totalPossible += possible;
      }
    }

    final overallRate = _percent(totalCompleted, totalPossible);
    overallCompletionRate.value = overallRate;
    performanceScore.value = overallRate;
    monthComparison.value =
        _percent(monthCompleted, monthPossible) - overallRate;

    final overallStreak = StreakCalculator.fromCompletedDays(
      activeDays,
      today: startOfToday,
    );
    overallCurrentStreak.value = overallStreak.current;
    overallBestStreak.value = overallStreak.best;

    weeklyCompleted.value = weekCompleted;
    weeklyTotal.value = weekPossible;

    final oldestFirst = trend30.reversed.toList();
    last30DaysTrend.assignAll(oldestFirst);
    last7DaysTrend.assignAll(oldestFirst.sublist(oldestFirst.length - 7));

    weekdayBreakdown.assignAll({
      for (final MapEntry(key: weekday, value: rates) in weekdayRates.entries)
        weekday: rates.reduce((a, b) => a + b) / rates.length,
    });
    currentWeekBreakdown.assignAll(currentWeek);
    heatmapData.assignAll(heatmap);

    // Ranked by id so two habits sharing a name aren't merged.
    final ranked = completionsById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    topHabits.assignAll(ranked.take(3).map((e) => nameById[e.key]!));
  }

  void _resetStats() {
    overallCompletionRate.value = 0;
    performanceScore.value = 0;
    monthComparison.value = 0;
    overallCurrentStreak.value = 0;
    overallBestStreak.value = 0;
    weeklyCompleted.value = 0;
    weeklyTotal.value = 0;
    last7DaysTrend.clear();
    last30DaysTrend.clear();
    weekdayBreakdown.clear();
    currentWeekBreakdown.clear();
    heatmapData.clear();
    topHabits.clear();
  }

  static double _percent(int part, int whole) =>
      whole == 0 ? 0 : part / whole * 100;
}
