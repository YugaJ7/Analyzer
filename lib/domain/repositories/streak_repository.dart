abstract class StreakRepository {
  Future<void> saveStreak(
    String userId,
    String parameterId,
    int current,
    int best,
    DateTime? lastCompletedDate,
  );

  Future<void> deleteStreak(String userId, String parameterId);

  /// Per-habit `currentStreak`, `bestStreak` and `lastCompletedDate`
  /// (a [DateTime] or null).
  Future<Map<String, Map<String, dynamic>>> getAllStreaks(String userId);
}
