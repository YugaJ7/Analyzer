abstract class StreakRepository {
  Future<void> saveStreak(
    String userId,
    String parameterId,
    int current,
    int best,
    DateTime? lastCompletedDate,
  );

  /// Per-habit `currentStreak`, `bestStreak` and `lastCompletedDate`
  /// (a [DateTime] or null).
  Future<Map<String, Map<String, dynamic>>> getAllStreaks(String userId);
}
