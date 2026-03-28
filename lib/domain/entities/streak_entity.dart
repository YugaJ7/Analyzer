import 'package:equatable/equatable.dart';

class StreakEntity extends Equatable {
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

  @override
  List<Object?> get props => [parameterId, currentStreak, bestStreak];
}