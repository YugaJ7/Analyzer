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

  Future<void> loadAllFromFirestore() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await streakRepository.getAllStreaks(userId);

    if (snapshot.isEmpty) return;

    final Map<String, int> currentMap = {};
    final Map<String, int> bestMap = {};

    snapshot.forEach((parameterId, data) {
      currentMap[parameterId] = (data['currentStreak'] as num?)?.toInt() ?? 0;
      bestMap[parameterId] = (data['bestStreak'] as num?)?.toInt() ?? 0;

      streakCache.save(
        parameterId,
        currentMap[parameterId]!,
        bestMap[parameterId]!,
      );
    });

    currentStreaks.assignAll(currentMap);
    bestStreaks.assignAll(bestMap);
  }

  void _loadFromCache() {
    final raw = streakCache.loadAll();
    if (raw.isEmpty) return;

    final Map<String, int> currentMap = {};
    final Map<String, int> bestMap = {};

    raw.forEach((habitId, data) {
      if (data is Map) {
        currentMap[habitId as String] = (data['current'] as num?)?.toInt() ?? 0;
        bestMap[habitId] = (data['best'] as num?)?.toInt() ?? 0;
      }
    });

    currentStreaks.assignAll(currentMap);
    bestStreaks.assignAll(bestMap);
  }

  void markToday(String parameterId, bool yesterdayCompleted) {
    int current = currentStreaks[parameterId] ?? 0;
    current = yesterdayCompleted ? current + 1 : 1;
    currentStreaks[parameterId] = current;

    if (current > (bestStreaks[parameterId] ?? 0)) {
      bestStreaks[parameterId] = current;
    }

    _persist(parameterId);
  }

  void unmarkToday(String parameterId, bool yesterdayCompleted) {
    int current = currentStreaks[parameterId] ?? 0;
    current = (yesterdayCompleted && current > 0) ? current - 1 : 0;
    currentStreaks[parameterId] = current;
    _persist(parameterId);
  }

  void _persist(String parameterId) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final current = currentStreaks[parameterId] ?? 0;
    final best = bestStreaks[parameterId] ?? 0;

    streakCache.save(parameterId, current, best);
    streakRepository.saveStreak(userId, parameterId, current, best);
  }

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
        temp = diff == 1 ? temp + 1 : 1;
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
