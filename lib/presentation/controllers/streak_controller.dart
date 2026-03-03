import 'dart:developer';

import 'package:analyzer/domain/entities/entry_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../domain/repositories/streak_repository.dart';
import '../../data/cache/streak_cache_service.dart';

class StreakController extends GetxController {
  final StreakRepository streakRepository;
  final StreakCacheService streakCache;

  StreakController({required this.streakRepository, required this.streakCache});

  final RxMap<String, int> currentStreaks = <String, int>{}.obs;

  final RxMap<String, int> bestStreaks = <String, int>{}.obs;
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    _loadFromCache();

    if (currentStreaks.isEmpty) {
      await loadAllFromFirestore();
    }
  }

  //Loading Streak from Firestore
  Future<void> loadAllFromFirestore() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await streakRepository.getAllStreaks(userId);

    if (snapshot.isEmpty) return;

    final Map<String, int> currentMap = {};
    final Map<String, int> bestMap = {};

    snapshot.forEach((parameterId, data) {
      currentMap[parameterId] = data['currentStreak'] ?? 0;
      bestMap[parameterId] = data['bestStreak'] ?? 0;

      streakCache.save(
        parameterId,
        currentMap[parameterId]!,
        bestMap[parameterId]!,
      );
    });

    currentStreaks.assignAll(currentMap);
    bestStreaks.assignAll(bestMap);
  }

  //Loading from Cache
  void _loadFromCache() {
    final raw = streakCache.loadAll();
    log("CACHE RAW: $raw");
    if (raw.isEmpty) return;

    final Map<String, int> currentMap = {};
    final Map<String, int> bestMap = {};

    log("ASSIGNING CURRENT: $currentMap");
    log("ASSIGNING BEST: $bestMap");

    raw.forEach((habitId, data) {
      if (data is Map) {
        currentMap[habitId] = data['current'] ?? 0;

        bestMap[habitId] = data['best'] ?? 0;
      }
    });

    currentStreaks.assignAll(currentMap);
    bestStreaks.assignAll(bestMap);
    log("AFTER ASSIGN currentStreaks: $currentStreaks");
  }

  // MARK TODAY
  void markToday(String parameterId, bool yesterdayCompleted) {
    int current = currentStreaks[parameterId] ?? 0;

    if (yesterdayCompleted) {
      current++;
    } else {
      current = 1;
    }

    currentStreaks[parameterId] = current;

    if (current > (bestStreaks[parameterId] ?? 0)) {
      bestStreaks[parameterId] = current;
    }

    _persist(parameterId);
  }

  /// UNMARK TODAY
  void unmarkToday(String parameterId, bool yesterdayCompleted) {
    int current = currentStreaks[parameterId] ?? 0;

    if (yesterdayCompleted && current > 0) {
      current = current - 1;
    } else {
      current = 0;
    }

    currentStreaks[parameterId] = current;

    _persist(parameterId);
  }

  //Saving to cache then firestore
  void _persist(String parameterId) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final current = currentStreaks[parameterId] ?? 0;
    final best = bestStreaks[parameterId] ?? 0;

    streakCache.save(parameterId, current, best);

    streakRepository.saveStreak(userId, parameterId, current, best);
  }

  //Recompute history streak if middle date is changed
  Future<void> recomputeFromHistory(
    String parameterId,
    Map<DateTime, List<EntryEntity>> history,
  ) async {
    final List<DateTime> dates = [];

    history.forEach((date, entries) {
      if (entries.any((e) => e.parameterId == parameterId)) {
        dates.add(DateTime(date.year, date.month, date.day));
      }
    });

    if (dates.isEmpty) {
      currentStreaks[parameterId] = 0;
      bestStreaks[parameterId] = 0;
      _persist(parameterId);
      return;
    }

    dates.sort();

    int best = 0;
    int temp = 0;
    DateTime? previous;

    for (final date in dates) {
      if (previous == null) {
        temp = 1;
      } else {
        final diff = date.difference(previous).inDays;
        if (diff == 1) {
          temp++;
        } else {
          temp = 1;
        }
      }

      if (temp > best) best = temp;
      previous = date;
    }

    int current = 0;

    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    final dateSet = dates.toSet();

    DateTime cursor = dateSet.contains(today) ? today : dates.last;

    while (dateSet.contains(cursor)) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    currentStreaks[parameterId] = current;
    bestStreaks[parameterId] = best;

    _persist(parameterId);
  }

  int getCurrent(String parameterId) => currentStreaks[parameterId] ?? 0;

  int getBest(String parameterId) => bestStreaks[parameterId] ?? 0;
}
