import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../domain/entities/entry_entity.dart';
import '../../domain/repositories/entry_repository.dart';
import '../../presentation/controllers/parameter_controller.dart';

class AnalyticsController extends GetxController {
  final EntryRepository entryRepository;
  final ParameterController parameterController;

  AnalyticsController({
    required this.entryRepository,
    required this.parameterController,
  });

  final RxBool isLoading = false.obs;

  /// 🔥 Raw data (90 days)
  final Map<DateTime, List<EntryEntity>> _history = {};

  /// 🔥 Computed Data
  final RxDouble performanceScore = 0.0.obs;
  final RxList<double> last7DaysTrend = <double>[].obs;
  final RxList<double> last30DaysTrend = <double>[].obs;
  final RxMap<int, double> weekdayBreakdown = <int, double>{}.obs;

  final RxInt totalActiveHabits = 0.obs;
  final RxDouble overallCompletionRate = 0.0.obs;
  final RxInt bestStreak = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    isLoading.value = true;

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final data =
        await entryRepository.getEntriesForLastNDays(userId, 90);

    _history.clear();
    _history.addAll(data);

    _computeAnalytics();

    isLoading.value = false;
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

    final Map<int, List<double>> weekdayMap = {};

    final List<double> trend7 = [];
    final List<double> trend30 = [];

    int currentStreak = 0;
    int longestStreak = 0;

    for (int i = 0; i < 90; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));

      final entries = _history[date] ?? [];

      int completedToday = 0;

      for (final habit in activeHabits) {
        final match = entries
            .any((e) => e.parameterId == habit.id);

        if (match) completedToday++;
      }

      final completionRate =
          activeHabits.isEmpty
              ? 0
              : completedToday / activeHabits.length;

      totalCompletions += completedToday;
      totalPossible += activeHabits.length;

      /// Weekday breakdown
      final weekday = date.weekday;
      weekdayMap.putIfAbsent(weekday, () => []);
      weekdayMap[weekday]!.add(completionRate as double);

      /// 7 day trend
      if (i < 7) {
        trend7.insert(0, completionRate * 100);
      }

      /// 30 day trend
      if (i < 30) {
        trend30.insert(0, completionRate * 100);
      }

      /// Streak calculation
      if (completionRate == 1.0) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    overallCompletionRate.value =
        totalPossible == 0
            ? 0
            : (totalCompletions / totalPossible) * 100;

    performanceScore.value =
        overallCompletionRate.value;

    last7DaysTrend.assignAll(trend7);
    last30DaysTrend.assignAll(trend30);

    bestStreak.value = longestStreak;

    /// Compute weekday average
    final Map<int, double> weekdayAverage = {};

    weekdayMap.forEach((weekday, list) {
      final avg = list.reduce((a, b) => a + b) /
          list.length;
      weekdayAverage[weekday] = avg * 100;
    });

    weekdayBreakdown.assignAll(weekdayAverage);
  }
}