class StreakEntity {
  final String parameterId;
  final int currentStreak;
  final int bestStreak;

  const StreakEntity({
    required this.parameterId,
    required this.currentStreak,
    required this.bestStreak,
  });

  StreakEntity copyWith({
    int? currentStreak,
    int? bestStreak,
  }) {
    return StreakEntity(
      parameterId: parameterId,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }
}