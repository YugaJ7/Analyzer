import 'dart:io';

import 'package:analyzer/core/utils/date_utils.dart';
import 'package:analyzer/data/cache/streak_cache_service.dart';
import 'package:analyzer/domain/entities/entry_entity.dart';
import 'package:analyzer/domain/repositories/entry_repository.dart';
import 'package:analyzer/domain/repositories/streak_repository.dart';
import 'package:analyzer/domain/usecases/entry_usecases.dart';
import 'package:analyzer/presentation/controllers/streak_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class _FakeStreakRepository implements StreakRepository {
  final saved = <String, (int, int, DateTime?)>{};

  @override
  Future<void> saveStreak(
    String userId,
    String parameterId,
    int current,
    int best,
    DateTime? lastCompletedDate,
  ) async {
    saved[parameterId] = (current, best, lastCompletedDate);
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAllStreaks(
    String userId,
  ) async => {};
}

/// History source that is always offline, so tests drive history explicitly.
class _OfflineEntryRepository implements EntryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('offline');
}

void main() {
  final today = DateTime(2026, 6, 15);
  DateTime daysAgo(int n) => AppDateUtils.addDays(today, -n);

  late Directory hiveDir;
  late StreakCacheService cache;
  late _FakeStreakRepository repository;

  setUp(() async {
    Get.testMode = true;
    hiveDir = await Directory.systemTemp.createTemp('streak_test');
    Hive.init(hiveDir.path);
    cache = StreakCacheService(await Hive.openBox<dynamic>('streaks'));
    repository = _FakeStreakRepository();
  });

  tearDown(() async {
    Get.reset();
    await Hive.deleteFromDisk();
    await hiveDir.delete(recursive: true);
  });

  /// Registers the controller like HomeBinding does, which loads the cache.
  StreakController createController() => Get.put(
    StreakController(
      streakRepository: repository,
      streakCache: cache,
      getEntriesForLastNDays: GetEntriesForLastNDays(_OfflineEntryRepository()),
      today: () => today,
      userId: () => 'uid-1',
    ),
  );

  Map<DateTime, List<EntryEntity>> historyFor(
    String parameterId,
    List<DateTime> days,
  ) => {
    for (final day in days)
      day: [
        EntryEntity(
          id: '$parameterId-$day',
          userId: 'uid-1',
          parameterId: parameterId,
          date: day,
          value: true,
          createdAt: day,
        ),
      ],
  };

  test('markToday extends a run that ended yesterday', () {
    final controller = createController()
      ..recomputeAllFromHistory(historyFor('h', [daysAgo(2), daysAgo(1)]));

    controller.markToday('h');

    expect(controller.getCurrent('h'), 3);
    expect(controller.getBest('h'), 3);
    expect(repository.saved['h'], (3, 3, today));
  });

  test('markToday restarts at 1 after a missed day', () {
    final controller = createController()
      ..recomputeAllFromHistory(
        historyFor('h', [daysAgo(4), daysAgo(3), daysAgo(2)]),
      );

    controller.markToday('h');

    expect(controller.getCurrent('h'), 1);
    expect(controller.getBest('h'), 3);
  });

  test('markToday twice on the same day counts once', () {
    final controller = createController()
      ..markToday('h')
      ..markToday('h');

    expect(controller.getCurrent('h'), 1);
  });

  test('unmarkToday reverts to the run ending yesterday', () {
    final controller = createController()
      ..recomputeAllFromHistory(historyFor('h', [daysAgo(1)]))
      ..markToday('h');

    controller.unmarkToday('h');

    expect(controller.getCurrent('h'), 1);
    expect(repository.saved['h']!.$3, daysAgo(1));
  });

  test('unmarkToday is a no-op when today was not recorded', () {
    final controller = createController()
      ..recomputeAllFromHistory(historyFor('h', [daysAgo(1)]));

    controller.unmarkToday('h');

    expect(controller.getCurrent('h'), 1);
  });

  test('a cached run decays to 0 once a day is missed', () {
    cache.save('h', 5, 5, daysAgo(2));

    final controller = createController();

    expect(controller.getCurrent('h'), 0);
    expect(controller.getBest('h'), 5);
  });

  test('a legacy cached run without a date is trusted until recomputed', () {
    cache.save('h', 7, 7, null);

    final controller = createController();

    expect(controller.getCurrent('h'), 7);
  });

  test('recompute never lowers a best set before the history window', () {
    cache.save('h', 0, 40, null);

    final controller = createController()
      ..recomputeAllFromHistory(historyFor('h', [daysAgo(1), today]));

    expect(controller.getCurrent('h'), 2);
    expect(controller.getBest('h'), 40);
  });

  test('skips persisting when nothing changed', () {
    final history = historyFor('h', [today]);
    final controller = createController()..recomputeAllFromHistory(history);
    repository.saved.clear();

    controller.recomputeAllFromHistory(history);

    expect(repository.saved, isEmpty);
  });
}
