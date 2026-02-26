import 'dart:developer';
import 'package:analyzer/data/cache/analytics_cache_service.dart';
import 'package:analyzer/presentation/controllers/streak_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../domain/entities/entry_entity.dart';
import '../../domain/repositories/entry_repository.dart';
import 'parameter_controller.dart';

class AnalyticsController extends GetxController {
  final EntryRepository entryRepository;
  final ParameterController parameterController;

  AnalyticsController({
    required this.entryRepository,
    required this.parameterController,
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

  final RxInt weeklyCompleted = 0.obs;
  final RxInt weeklyTotal = 0.obs;

  final RxDouble monthComparison = 0.0.obs;

  final RxList<String> topHabits = <String>[].obs;

  final RxMap<DateTime, double> heatmapData = <DateTime, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    isLoading.value = true;

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final data = await entryRepository.getEntriesForLastNDays(userId, 365);

    log("Loaded history days: ${data.length}");

    _history
      ..clear()
      ..addAll(data);

    _computeAnalytics();
    Get.find<StreakController>().loadAllStreaks();
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
    final cache = Get.find<AnalyticsCacheService>();
    cache.save(_history);
    _computeAnalytics();
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

    int currentStreak = 0;
    int bestStreak = 0;

    int weeklyComp = 0;
    int weeklyPoss = 0;

    final Map<int, List<double>> weekdayMap = {};
    final Map<String, int> habitCount = {};

    final List<double> trend7 = [];
    final List<double> trend30 = [];

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
        weeklyComp += completedToday;
        weeklyPoss += activeHabits.length;
        trend7.insert(0, completionRate * 100);
      }

      if (i < 30) {
        trend30.insert(0, completionRate * 100);
      }

      weekdayMap.putIfAbsent(date.weekday, () => []);
      weekdayMap[date.weekday]!.add(completionRate);

      if (completedToday > 0) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    overallCompletionRate.value = totalPossible == 0
        ? 0
        : (totalCompletions / totalPossible) * 100;

    performanceScore.value = overallCompletionRate.value;

    overallCurrentStreak.value = currentStreak;
    overallBestStreak.value = bestStreak;

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

    if (trend30.isNotEmpty) {
      final lastMonthAvg = trend30.reduce((a, b) => a + b) / trend30.length;

      monthComparison.value = lastMonthAvg - overallCompletionRate.value;
    }

    final sorted = habitCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topHabits.assignAll(sorted.take(3).map((e) => e.key));
  }
}
