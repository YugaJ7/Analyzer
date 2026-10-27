import 'dart:io';

import 'package:analyzer/core/errors/app_exception.dart';
import 'package:analyzer/core/errors/failures.dart';
import 'package:analyzer/data/cache/analytics_cache_service.dart';
import 'package:analyzer/data/cache/streak_cache_service.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:analyzer/domain/entities/entry_entity.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:analyzer/domain/repositories/entry_repository.dart';
import 'package:analyzer/domain/repositories/parameter_repository.dart';
import 'package:analyzer/domain/repositories/streak_repository.dart';
import 'package:analyzer/domain/usecases/entry_usecases.dart';
import 'package:analyzer/domain/usecases/parameter_usecases.dart';
import 'package:analyzer/presentation/controllers/analytics_controller.dart';
import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:analyzer/presentation/controllers/streak_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

const _writeFailure = AppException(ServerFailure('write failed'));

/// Records every call so tests can assert on order; any op can be failed.
final _calls = <String>[];

class _FakeEntryRepository implements EntryRepository {
  final failing = <String>{};

  Future<void> _record(String op) async {
    _calls.add(op);
    if (failing.contains(op)) throw _writeFailure;
  }

  @override
  Future<List<EntryEntity>> getEntriesForDate(String u, DateTime d) async => [];

  @override
  Future<Map<DateTime, List<EntryEntity>>> getEntriesForLastNDays(
    String u,
    int days,
  ) async => {};

  @override
  Future<void> saveEntry(EntryEntity e) => _record('save:${e.parameterId}');

  @override
  Future<void> updateEntry(
    String u,
    DateTime d,
    String id,
    Map<String, dynamic> updates,
  ) => _record('update:$id');

  @override
  Future<void> deleteEntry(String u, DateTime d, String id) =>
      _record('delete:$id');

  @override
  Future<void> deleteAllEntriesForParameter(String u, String id) =>
      _record('deleteEntries:$id');
}

class _FakeStreakRepository implements StreakRepository {
  @override
  Future<void> saveStreak(
    String u,
    String id,
    int c,
    int b,
    DateTime? l,
  ) async {}

  @override
  Future<void> deleteStreak(String u, String id) async =>
      _calls.add('deleteStreak:$id');

  @override
  Future<Map<String, Map<String, dynamic>>> getAllStreaks(String u) async => {};
}

class _FakeParameterRepository implements ParameterRepository {
  final failing = <String>{};

  @override
  Future<void> deleteParameter(String u, String id) async {
    _calls.add('deleteParameter:$id');
    if (failing.contains('deleteParameter')) throw _writeFailure;
  }

  @override
  Future<void> reorderParameters(String u, List<String> ids) async {
    if (failing.contains('reorder')) throw _writeFailure;
  }

  @override
  Stream<List<ParameterEntity>> watchParameters(String u) =>
      const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ParameterModel _habit(String id, int order) => ParameterModel(
  id: id,
  userId: 'uid-1',
  createdAt: DateTime(2026),
  name: id,
  type: ParameterType.checklist,
  order: order,
);

void main() {
  final today = DateTime(2026, 6, 15);

  late Directory hiveDir;
  late _FakeEntryRepository entryRepo;
  late _FakeParameterRepository parameterRepo;
  late StreakController streaks;
  late AnalyticsController analytics;
  late ParameterController habits;
  late EntryController entries;

  setUp(() async {
    Get.testMode = true;
    _calls.clear();
    hiveDir = await Directory.systemTemp.createTemp('mutation_test');
    Hive.init(hiveDir.path);

    entryRepo = _FakeEntryRepository();
    parameterRepo = _FakeParameterRepository();
    streaks = StreakController(
      streakRepository: _FakeStreakRepository(),
      streakCache: StreakCacheService(await Hive.openBox<dynamic>('s')),
      getEntriesForLastNDays: GetEntriesForLastNDays(entryRepo),
      today: () => today,
      userId: () => 'uid-1',
    );
    habits = ParameterController(
      getParameters: GetParameters(parameterRepo),
      addParameter: AddParameter(parameterRepo),
      updateParameter: UpdateParameter(parameterRepo),
      deleteParameter: DeleteParameter(parameterRepo),
      watchParameters: WatchParameters(parameterRepo),
      reorderParameters: ReorderParameters(parameterRepo),
      deleteAllEntriesForParameter: DeleteAllEntriesForParameter(entryRepo),
      userId: () => 'uid-1',
      streaks: () => streaks,
      analytics: () => analytics,
      syncWidget: () async {},
    );
    analytics = AnalyticsController(
      entryRepository: entryRepo,
      parameterController: habits,
      cacheService: AnalyticsCacheService(await Hive.openBox<dynamic>('a')),
    );
    entries = EntryController(
      getEntriesForDate: GetEntriesForDate(entryRepo),
      saveEntry: SaveEntry(entryRepo),
      updateEntry: UpdateEntry(entryRepo),
      deleteEntry: DeleteEntry(entryRepo),
      today: () => today,
      userId: () => 'uid-1',
      syncWidget: () async {},
      analytics: () => analytics,
      streaks: () => streaks,
    );
    await entries.loadEntries();
  });

  tearDown(() async {
    Get.reset();
    await Hive.deleteFromDisk();
    await hiveDir.delete(recursive: true);
  });

  bool inHistory(String id) =>
      analytics.history[today]?.any((e) => e.parameterId == id) ?? false;

  group('EntryController.toggleEntry', () {
    test('applies a completion to entries, analytics and streak', () async {
      await entries.toggleEntry('h', true, syncWidget: false);

      expect(entries.selectedDateEntries.keys, ['h']);
      expect(inHistory('h'), isTrue);
      expect(streaks.getCurrent('h'), 1);
      expect(_calls, ['save:h']);
    });

    test('rolls everything back when the save fails', () async {
      entryRepo.failing.add('save:h');

      await entries.toggleEntry('h', true, syncWidget: false);

      expect(entries.selectedDateEntries, isEmpty);
      expect(inHistory('h'), isFalse);
      expect(streaks.getCurrent('h'), 0);
    });

    test('restores the entry when an un-tick fails to delete', () async {
      await entries.toggleEntry('h', true, syncWidget: false);
      entryRepo.failing.add('delete:h');

      await entries.toggleEntry('h', true, syncWidget: false);

      expect(entries.selectedDateEntries.keys, ['h']);
      expect(inHistory('h'), isTrue);
      expect(streaks.getCurrent('h'), 1);
    });

    test('a value edit updates without touching completion stats', () async {
      await entries.toggleEntry('h', 3, syncWidget: false);

      await entries.toggleEntry('h', 5, syncWidget: false);

      expect(entries.selectedDateEntries['h']!.value, 5);
      expect(streaks.getCurrent('h'), 1);
      expect(_calls, ['save:h', 'update:h']);
    });
  });

  group('EntryController widget actions', () {
    test('rolls back only the failed action and rethrows', () async {
      entryRepo.failing.add('save:bad');

      await expectLater(
        entries.applyTodayWidgetActionsOptimistically([
          {'parameterId': 'ok', 'type': 'checklist', 'done': true},
          {'parameterId': 'bad', 'type': 'checklist', 'done': true},
        ]),
        throwsA(same(_writeFailure)),
      );

      expect(entries.selectedDateEntries.keys, ['ok']);
      expect(inHistory('bad'), isFalse);
      expect(streaks.getCurrent('bad'), 0);
    });

    test('skips actions that change nothing', () async {
      await entries.applyTodayWidgetActionsOptimistically([
        {'parameterId': 'h', 'type': 'checklist', 'done': false},
        {'parameterId': 'o', 'type': 'optionSelector', 'value': ''},
      ]);

      expect(_calls, isEmpty);
    });
  });

  group('ParameterController', () {
    setUp(() => habits.parameters.assignAll([_habit('a', 0), _habit('b', 1)]));

    test('deletes dependents before the habit document', () async {
      expect(await habits.deleteExistingParameter('a'), isTrue);

      expect(_calls, [
        'deleteEntries:a',
        'deleteStreak:a',
        'deleteParameter:a',
      ]);
      expect(habits.parameters.map((p) => p.id), ['b']);
    });

    test('restores the habit in place when the delete fails', () async {
      parameterRepo.failing.add('deleteParameter');

      expect(await habits.deleteExistingParameter('a'), isFalse);

      expect(habits.parameters.map((p) => p.id), ['a', 'b']);
      expect(habits.getFromCache('a'), isNotNull);
    });

    test('reorders locally and rolls back when the batch fails', () async {
      parameterRepo.failing.add('reorder');

      expect(await habits.reorderParameterList(0, 2), isFalse);

      expect(habits.parameters.map((p) => p.id), ['a', 'b']);
    });

    test('reorder assigns order by position', () async {
      expect(await habits.reorderParameterList(0, 2), isTrue);

      expect(habits.parameters.map((p) => (p.id, p.order)), [
        ('b', 0),
        ('a', 1),
      ]);
    });
  });
}
