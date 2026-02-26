import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../domain/repositories/entry_repository.dart';
import '../../domain/repositories/streak_repository.dart';

class StreakController extends GetxController {
  final EntryRepository entryRepository;
  final StreakRepository streakRepository;

  StreakController({
    required this.entryRepository,
    required this.streakRepository,
  });

  final RxMap<String, int> currentStreaks =
      <String, int>{}.obs;

  final RxMap<String, int> bestStreaks =
      <String, int>{}.obs;

  Future<void> recalculate(
      String parameterId) async {
    final userId =
        FirebaseAuth.instance.currentUser!.uid;

    final history =
        await entryRepository
            .getEntriesForLastNDays(
                userId, 365);

    final dates = history.entries
        .where((entry) => entry.value.any(
            (e) =>
                e.parameterId ==
                parameterId))
        .map((e) => e.key)
        .toList()
      ..sort();

    int best = 0;
    int current = 0;

    DateTime? previous;

    for (final date in dates) {
      if (previous == null) {
        current = 1;
      } else {
        final diff =
            date.difference(previous)
                .inDays;

        if (diff == 1) {
          current++;
        } else {
          current = 1;
        }
      }

      if (current > best) {
        best = current;
      }

      previous = date;
    }

    currentStreaks[parameterId] =
        current;
    bestStreaks[parameterId] = best;

    await streakRepository.saveStreak(
      userId,
      parameterId,
      current,
      best,
    );
  }

  int getCurrent(String parameterId) =>
      currentStreaks[parameterId] ?? 0;

  int getBest(String parameterId) =>
      bestStreaks[parameterId] ?? 0;
}