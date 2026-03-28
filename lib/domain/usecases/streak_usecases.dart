import '../repositories/streak_repository.dart';

class GetAllStreaks {
  final StreakRepository repository;
  GetAllStreaks(this.repository);

  Future<Map<String, Map<String, dynamic>>> call(String userId) {
    return repository.getAllStreaks(userId);
  }
}

class SaveStreak {
  final StreakRepository repository;
  SaveStreak(this.repository);

  Future<void> call(
    String userId,
    String parameterId,
    int current,
    int best,
  ) {
    return repository.saveStreak(userId, parameterId, current, best);
  }
}
