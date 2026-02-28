
import 'package:get/get.dart';
import '../../presentation/controllers/analytics_controller.dart';
import '../../domain/repositories/streak_repository.dart';

class StreakController extends GetxController {
  final StreakRepository streakRepository;

  StreakController({
    required this.streakRepository,
  });

  final RxMap<String, int> currentStreaks =
      <String, int>{}.obs;

  final RxMap<String, int> bestStreaks =
      <String, int>{}.obs;

  /// Initial load 
  void loadAllStreaks() {
    final analytics =
        Get.find<AnalyticsController>();

    final history = analytics.history;

    final Map<String, List<DateTime>> habitDates =
        {};

    history.forEach((date, entries) {
      for (final e in entries) {
        habitDates.putIfAbsent(
            e.parameterId, () => []);
        habitDates[e.parameterId]!
            .add(date);
      }
    });

    habitDates.forEach((parameterId, dates) {
      _computeAndSet(parameterId, dates);
    });
  }

  /// Instant update for single habit
  void updateSingleHabit(String parameterId) {
    final analytics =
        Get.find<AnalyticsController>();

    final history = analytics.history;

    final List<DateTime> dates = [];

    history.forEach((date, entries) {
      if (entries.any(
          (e) => e.parameterId == parameterId)) {
        dates.add(date);
      }
    });

    _computeAndSet(parameterId, dates);
  }

  /// Core calculation (fast + sync)
  void _computeAndSet(
  String parameterId,
  List<DateTime> dates,
) {
  if (dates.isEmpty) {
    currentStreaks[parameterId] = 0;
    bestStreaks[parameterId] = 0;
    return;
  }

  dates.sort();

  final dateSet = dates
      .map((d) => DateTime(d.year, d.month, d.day))
      .toSet();

  // BEST STREAK
  int best = 0;
  int temp = 0;
  DateTime? previous;

  for (final date in dates) {
    if (previous == null) {
      temp = 1;
    } else {
      final diff =
          date.difference(previous).inDays;

      if (diff == 1) {
        temp++;
      } else {
        temp = 1;
      }
    }

    if (temp > best) {
      best = temp;
    }

    previous = date;
  }

  // CURRENT STREAK (anchored to today)
  int current = 0;
  DateTime cursor = DateTime.now();
  cursor = DateTime(cursor.year, cursor.month, cursor.day);

  while (dateSet.contains(cursor)) {
    current++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  // Memory update only
  currentStreaks[parameterId] = current;
  bestStreaks[parameterId] = best;

}

  int getCurrent(String parameterId) =>
      currentStreaks[parameterId] ?? 0;

  int getBest(String parameterId) =>
      bestStreaks[parameterId] ?? 0;
}