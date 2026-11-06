import '../../core/utils/date_utils.dart';

class StreakResult {
  const StreakResult({
    required this.current,
    required this.best,
    this.lastCompletedDate,
  });

  static const empty = StreakResult(current: 0, best: 0);

  final int current;
  final int best;
  final DateTime? lastCompletedDate;
}

abstract final class StreakCalculator {
  /// Derives streaks from the set of days a habit was completed.
  ///
  /// The current run may end today or yesterday (today is still open); any
  /// older run is broken and counts as 0.
  static StreakResult fromCompletedDays(
    Iterable<DateTime> completedDays, {
    required DateTime today,
  }) {
    final days = completedDays.map(AppDateUtils.dateOnly).toSet().toList()
      ..sort();
    if (days.isEmpty) return StreakResult.empty;

    var best = 0;
    var run = 0;
    DateTime? previous;
    for (final day in days) {
      final isConsecutive =
          previous != null && AppDateUtils.daysBetween(previous, day) == 1;
      run = isConsecutive ? run + 1 : 1;
      if (run > best) best = run;
      previous = day;
    }

    final last = days.last;
    final current = isAlive(last, today: today) ? run : 0;
    return StreakResult(current: current, best: best, lastCompletedDate: last);
  }

  /// Whether a run whose last completion was [lastCompleted] still counts.
  static bool isAlive(DateTime? lastCompleted, {required DateTime today}) {
    if (lastCompleted == null) return false;
    final gap = AppDateUtils.daysBetween(lastCompleted, today);
    return gap == 0 || gap == 1;
  }
}
