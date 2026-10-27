import 'dart:async';
import 'dart:math' show max;

import 'package:analyzer/domain/entities/entry_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/repositories/streak_repository.dart';
import '../../domain/services/streak_calculator.dart';
import '../../domain/usecases/entry_usecases.dart';
import '../../data/cache/streak_cache_service.dart';

class StreakController extends GetxController {
  final StreakRepository streakRepository;
  final StreakCacheService streakCache;
  final GetEntriesForLastNDays getEntriesForLastNDays;
  final DateTime Function() _today;
  final String Function() _userId;

  StreakController({
    required this.streakRepository,
    required this.streakCache,
    required this.getEntriesForLastNDays,
    DateTime Function()? today,
    String Function()? userId,
  }) : _today = today ?? AppDateUtils.today,
       _userId = userId ?? (() => FirebaseAuth.instance.currentUser!.uid);

  static const _historyWindowDays = 365;

  final RxMap<String, int> currentStreaks = <String, int>{}.obs;
  final RxMap<String, int> bestStreaks = <String, int>{}.obs;
  final Map<String, DateTime?> _lastCompleted = {};

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    _loadFromCache();
    try {
      if (currentStreaks.isEmpty) await loadAllFromFirestore();
      // History is the source of truth: heals legacy records and picks up
      // edits made on other devices.
      final history = await getEntriesForLastNDays(
        _userId(),
        _historyWindowDays,
      );
      recomputeAllFromHistory(history);
    } catch (error, stackTrace) {
      // Cached values stay usable; getCurrent() still decays stale runs.
      AppLogger.error(
        'Streak refresh failed',
        name: 'StreakController',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> loadAllFromFirestore() async {
    final snapshot = await streakRepository.getAllStreaks(_userId());
    snapshot.forEach((parameterId, data) {
      _apply(
        parameterId,
        current: (data['currentStreak'] as num?)?.toInt() ?? 0,
        best: (data['bestStreak'] as num?)?.toInt() ?? 0,
        lastCompleted: data['lastCompletedDate'] as DateTime?,
      );
      _saveToCache(parameterId);
    });
  }

  void _loadFromCache() {
    streakCache.loadAll().forEach((habitId, data) {
      if (habitId is! String || data is! Map) return;
      final last = data['last'];
      _apply(
        habitId,
        current: (data['current'] as num?)?.toInt() ?? 0,
        best: (data['best'] as num?)?.toInt() ?? 0,
        lastCompleted: last is String ? DateTime.tryParse(last) : null,
      );
    });
  }

  /// Records a completion for today, extending the run if it ended yesterday.
  void markToday(String parameterId) {
    final today = _today();
    final last = _lastCompleted[parameterId];
    if (last != null && AppDateUtils.daysBetween(last, today) == 0) return;

    final continues =
        last != null && AppDateUtils.daysBetween(last, today) == 1;
    final current = continues ? getCurrent(parameterId) + 1 : 1;
    _update(
      parameterId,
      current: current,
      best: max(getBest(parameterId), current),
      lastCompleted: today,
    );
  }

  /// Reverts today's completion; the run then ends yesterday, if at all.
  void unmarkToday(String parameterId) {
    final today = _today();
    final last = _lastCompleted[parameterId];
    if (last == null || AppDateUtils.daysBetween(last, today) != 0) return;

    final current = max(getCurrent(parameterId) - 1, 0);
    _update(
      parameterId,
      current: current,
      best: getBest(parameterId),
      lastCompleted: current > 0 ? AppDateUtils.addDays(today, -1) : null,
    );
  }

  Future<void> recomputeFromHistory(
    String parameterId,
    Map<DateTime, List<EntryEntity>> history,
  ) async {
    _recompute(parameterId, history);
  }

  void recomputeAllFromHistory(Map<DateTime, List<EntryEntity>> history) {
    final ids = {
      ...currentStreaks.keys,
      for (final entries in history.values)
        ...entries.map((e) => e.parameterId),
    };
    for (final id in ids) {
      _recompute(id, history);
    }
  }

  void _recompute(
    String parameterId,
    Map<DateTime, List<EntryEntity>> history,
  ) {
    final completedDays = [
      for (final MapEntry(key: date, value: entries) in history.entries)
        if (entries.any((e) => e.parameterId == parameterId)) date,
    ];
    final result = StreakCalculator.fromCompletedDays(
      completedDays,
      today: _today(),
    );
    _update(
      parameterId,
      current: result.current,
      // History only spans the window; never shrink a best set before it.
      best: max(result.best, bestStreaks[parameterId] ?? 0),
      lastCompleted: result.lastCompletedDate,
    );
  }

  int getCurrent(String parameterId) {
    final current = currentStreaks[parameterId] ?? 0;
    final last = _lastCompleted[parameterId];
    // Null = legacy record without a date; trusted until recomputed.
    if (last == null) return current;
    return StreakCalculator.isAlive(last, today: _today()) ? current : 0;
  }

  int getBest(String parameterId) => bestStreaks[parameterId] ?? 0;

  void _apply(
    String parameterId, {
    required int current,
    required int best,
    required DateTime? lastCompleted,
  }) {
    currentStreaks[parameterId] = current;
    bestStreaks[parameterId] = best;
    _lastCompleted[parameterId] = lastCompleted;
  }

  /// Applies and persists, skipping the write when nothing changed.
  void _update(
    String parameterId, {
    required int current,
    required int best,
    required DateTime? lastCompleted,
  }) {
    final unchanged =
        currentStreaks[parameterId] == current &&
        bestStreaks[parameterId] == best &&
        _lastCompleted.containsKey(parameterId) &&
        _lastCompleted[parameterId] == lastCompleted;
    if (unchanged) return;

    _apply(
      parameterId,
      current: current,
      best: best,
      lastCompleted: lastCompleted,
    );
    _saveToCache(parameterId);
    // Fire-and-forget: the cache is authoritative locally and the next
    // recompute re-persists, so a failed write only needs logging.
    unawaited(
      streakRepository
          .saveStreak(_userId(), parameterId, current, best, lastCompleted)
          .catchError((Object error, StackTrace stackTrace) {
            AppLogger.error(
              'Streak save failed',
              name: 'StreakController',
              error: error,
              stackTrace: stackTrace,
            );
          }),
    );
  }

  void _saveToCache(String parameterId) {
    streakCache.save(
      parameterId,
      currentStreaks[parameterId] ?? 0,
      bestStreaks[parameterId] ?? 0,
      _lastCompleted[parameterId],
    );
  }
}
