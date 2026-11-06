import 'package:analyzer/core/utils/date_utils.dart';
import 'package:analyzer/domain/services/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 6, 15);
  DateTime daysAgo(int n) => AppDateUtils.addDays(today, -n);

  group('AppDateUtils', () {
    test('addDays lands on midnight of the target calendar day', () {
      // 2026-03-08 is 23h long where US DST applies; a 24h shift overshoots.
      expect(
        AppDateUtils.addDays(DateTime(2026, 3, 8), 1),
        DateTime(2026, 3, 9),
      );
      expect(
        AppDateUtils.addDays(DateTime(2026, 3, 9), -1),
        DateTime(2026, 3, 8),
      );
    });

    test('addDays rolls over month and year boundaries', () {
      expect(AppDateUtils.addDays(DateTime(2026), -1), DateTime(2025, 12, 31));
      expect(AppDateUtils.addDays(DateTime(2026, 2, 28), 1), DateTime(2026, 3));
    });

    test('daysBetween counts calendar days regardless of time and DST', () {
      expect(
        AppDateUtils.daysBetween(
          DateTime(2026, 3, 8, 23),
          DateTime(2026, 3, 9),
        ),
        1,
      );
      expect(
        AppDateUtils.daysBetween(DateTime(2026, 11), DateTime(2026, 11, 2)),
        1,
      );
    });
  });

  group('StreakCalculator.fromCompletedDays', () {
    test('returns zeros for no completions', () {
      final result = StreakCalculator.fromCompletedDays([], today: today);

      expect(result.current, 0);
      expect(result.best, 0);
      expect(result.lastCompletedDate, isNull);
    });

    test('counts a run ending today', () {
      final result = StreakCalculator.fromCompletedDays([
        daysAgo(2),
        daysAgo(1),
        today,
      ], today: today);

      expect(result.current, 3);
      expect(result.best, 3);
      expect(result.lastCompletedDate, today);
    });

    test('keeps a run ending yesterday alive while today is open', () {
      final result = StreakCalculator.fromCompletedDays([
        daysAgo(2),
        daysAgo(1),
      ], today: today);

      expect(result.current, 2);
    });

    test('breaks a run whose last completion is older than yesterday', () {
      final result = StreakCalculator.fromCompletedDays([
        daysAgo(5),
        daysAgo(4),
        daysAgo(3),
        daysAgo(2),
      ], today: today);

      expect(result.current, 0);
      expect(result.best, 4);
    });

    test('reports the longest run as best, not the latest', () {
      final result = StreakCalculator.fromCompletedDays([
        daysAgo(10),
        daysAgo(9),
        daysAgo(8),
        daysAgo(1),
        today,
      ], today: today);

      expect(result.current, 2);
      expect(result.best, 3);
    });

    test('ignores time of day and duplicate entries', () {
      final result = StreakCalculator.fromCompletedDays([
        daysAgo(1).add(const Duration(hours: 22)),
        daysAgo(1),
        today.add(const Duration(hours: 7)),
      ], today: today);

      expect(result.current, 2);
    });

    test('stays continuous across a DST transition', () {
      final result = StreakCalculator.fromCompletedDays([
        DateTime(2026, 3, 7),
        DateTime(2026, 3, 8),
        DateTime(2026, 3, 9),
      ], today: DateTime(2026, 3, 9));

      expect(result.current, 3);
    });
  });
}
