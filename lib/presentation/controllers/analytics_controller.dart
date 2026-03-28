import 'package:analyzer/data/cache/analytics_cache_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../domain/entities/entry_entity.dart';
import '../../domain/repositories/entry_repository.dart';
import 'parameter_controller.dart';

class AnalyticsController extends GetxController {
  final EntryRepository entryRepository;
  final ParameterController parameterController;
  final AnalyticsCacheService cacheService;

  AnalyticsController({
    required this.entryRepository,
    required this.parameterController,
    required this.cacheService,
  });

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

    // Recompute when parameters change (covers initial load race condition
    // where parameters arrive after entries are already fetched)
    ever(parameterController.parameters, (_) {
      if (_history.isNotEmpty) {
        _computeAnalytics();
      }
    });
  }

  Future<void> loadAnalytics() async {
    isLoading.value = true;
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final data = await entryRepository.getEntriesForLastNDays(userId, 365);

    _history
      ..clear()
      ..addAll(data);

    _computeAnalytics();
    isLoading.value = false;
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

  void _computeAnalytics() {
    final activeHabits = parameterController.parameters
        .where((p) => p.isActive)
        .toList();

    totalActiveHabits.value = activeHabits.length;
    if (activeHabits.isEmpty) return;

    final now = DateTime.now();

    int totalCompletions = 0;
    int totalPossible = 0;

    int overallCurrent = 0;
    int overallBest = 0;

    int weeklyComp = 0;
    int weeklyPoss = 0;

    final Map<int, List<double>> weekdayMap = {};
    final Map<int, double> currentWeekMap = {
      1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0
    };
    final Map<String, int> habitCount = {};

    final List<double> trend7 = [];
    final List<double> trend30 = [];

    final startOfToday = DateTime(now.year, now.month, now.day);
    final mondayOfThisWeek = startOfToday.subtract(Duration(days: now.weekday - 1));

    heatmapData.clear();

    for (int i = 0; i < 365; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));

      final entries = _history[date] ?? [];

      int completedToday = 0;

      for (final habit in activeHabits) {
        final matched = entries.any((e) => e.parameterId == habit.id);

        if (matched) {
          completedToday++;
          habitCount[habit.name] = (habitCount[habit.name] ?? 0) + 1;
        }
      }

      final completionRate = completedToday / activeHabits.length;

      totalCompletions += completedToday;
      totalPossible += activeHabits.length;

      heatmapData[date] = completionRate * 100;

      if (i < 7) {
        trend7.insert(0, completionRate * 100);
      }

      if (!date.isBefore(mondayOfThisWeek)) {
        weeklyComp += completedToday;
        weeklyPoss += activeHabits.length;
        currentWeekMap[date.weekday] = completionRate * 100;
      }

      if (i < 30) {
        trend30.insert(0, completionRate * 100);
      }

      weekdayMap.putIfAbsent(date.weekday, () => []);
      weekdayMap[date.weekday]!.add(completionRate);

      if (completedToday > 0) {
        overallCurrent++;
        if (overallCurrent > overallBest) {
          overallBest = overallCurrent;
        }
      } else {
        overallCurrent = 0;
      }
    }

    overallCompletionRate.value = totalPossible == 0
        ? 0
        : (totalCompletions / totalPossible) * 100;

    performanceScore.value = overallCompletionRate.value;

    overallCurrentStreak.value = overallCurrent;
    overallBestStreak.value = overallBest;

    weeklyCompleted.value = weeklyComp;
    weeklyTotal.value = weeklyPoss;

    last7DaysTrend.assignAll(trend7);
    last30DaysTrend.assignAll(trend30);

    final Map<int, double> weekdayAvg = {};
    weekdayMap.forEach((weekday, list) {
      final avg = list.reduce((a, b) => a + b) / list.length;
      weekdayAvg[weekday] = avg * 100;
    });

    weekdayBreakdown.assignAll(weekdayAvg);
    currentWeekBreakdown.assignAll(currentWeekMap);

    if (trend30.isNotEmpty) {
      final lastMonthAvg = trend30.reduce((a, b) => a + b) / trend30.length;

      monthComparison.value = lastMonthAvg - overallCompletionRate.value;
    }

    final sorted = habitCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topHabits.assignAll(sorted.take(3).map((e) => e.key));
  }
}
