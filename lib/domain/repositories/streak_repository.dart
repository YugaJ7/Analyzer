abstract class StreakRepository {
  Future<void> saveStreak(
    String userId,
    String parameterId,
    int current,
    int best,
  );

  Future<Map<String, dynamic>?> getStreak(
    String userId,
    String parameterId,
  );
}