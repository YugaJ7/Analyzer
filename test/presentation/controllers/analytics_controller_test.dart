import 'dart:io';

import 'package:analyzer/core/utils/date_utils.dart';
import 'package:analyzer/data/cache/analytics_cache_service.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:analyzer/domain/entities/entry_entity.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:analyzer/domain/repositories/entry_repository.dart';
import 'package:analyzer/domain/repositories/parameter_repository.dart';
import 'package:analyzer/domain/usecases/entry_usecases.dart';
import 'package:analyzer/domain/usecases/parameter_usecases.dart';
import 'package:analyzer/presentation/controllers/analytics_controller.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

final _today = DateTime(2026, 6, 15);

class _FakeEntryRepository implements EntryRepository {
  Map<DateTime, List<EntryEntity>> history = {};

  @override
  Future<Map<DateTime, List<EntryEntity>>> getEntriesForLastNDays(
    String u,
    int days,
  ) async => history;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeParameterRepository implements ParameterRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ParameterModel _habit(String id, {String? name, int createdDaysAgo = 400}) =>
    ParameterModel(
      id: id,
      userId: 'uid-1',
      createdAt: AppDateUtils.addDays(_today, -createdDaysAgo),
      name: name ?? id,
      type: ParameterType.checklist,
      order: 0,
    );

EntryEntity _done(String id, int daysAgo) => EntryEntity(
  id: '$id-$daysAgo',
  userId: 'uid-1',
  parameterId: id,
  date: AppDateUtils.addDays(_today, -daysAgo),
  value: true,
  createdAt: _today,
);

/// Each habit in [ids] completed on each of the last [days] days.
Map<DateTime, List<EntryEntity>> _history(List<String> ids, int days) => {
  for (var i = 0; i < days; i++)
    AppDateUtils.addDays(_today, -i): [for (final id in ids) _done(id, i)],
};

void main() {
  late Directory hiveDir;
  late _FakeEntryRepository entryRepo;
  late ParameterController habits;
  late AnalyticsController analytics;

  setUp(() async {
    Get.testMode = true;
    hiveDir = await Directory.systemTemp.createTemp('analytics_test');
    Hive.init(hiveDir.path);

    entryRepo = _FakeEntryRepository();
    final parameterRepo = _FakeParameterRepository();
    habits = ParameterController(
      getParameters: GetParameters(parameterRepo),
      addParameter: AddParameter(parameterRepo),
      updateParameter: UpdateParameter(parameterRepo),
      deleteParameter: DeleteParameter(parameterRepo),
      watchParameters: WatchParameters(parameterRepo),
      reorderParameters: ReorderParameters(parameterRepo),
      deleteAllEntriesForParameter: DeleteAllEntriesForParameter(entryRepo),
      userId: () => 'uid-1',
      syncWidget: () async {},
    );
    analytics = Get.put(
      AnalyticsController(
        entryRepository: entryRepo,
        parameterController: habits,
        cacheService: AnalyticsCacheService(await Hive.openBox<dynamic>('a')),
        today: () => _today,
        userId: () => 'uid-1',
      ),
    );
  });

  tearDown(() async {
    Get.reset();
    await Hive.deleteFromDisk();
    await hiveDir.delete(recursive: true);
  });

  Future<void> load(
    List<ParameterModel> active,
    Map<DateTime, List<EntryEntity>> history,
  ) async {
    habits.parameters.assignAll(active);
    entryRepo.history = history;
    await analytics.loadAnalytics();
  }

  test('ignores days before a habit was created', () async {
    await load([_habit('a', createdDaysAgo: 9)], _history(['a'], 10));

    expect(analytics.overallCompletionRate.value, 100);
    expect(analytics.monthComparison.value, 0);
    expect(analytics.weekdayBreakdown.values, everyElement(100));
  });

  test('a new habit does not dilute days it did not exist on', () async {
    await load([
      _habit('old', createdDaysAgo: 2),
      _habit('new', createdDaysAgo: 0),
    ], _history(['old'], 3));

    // Two days with only `old` at 100%, then today at 1 of 2.
    expect(analytics.last7DaysTrend.sublist(4), [100, 100, 50]);
    expect(analytics.overallCompletionRate.value, closeTo(75, 0.001));
  });

  test('clears every stat when the last habit is removed', () async {
    await load([_habit('a')], _history(['a'], 5));
    expect(analytics.overallCurrentStreak.value, 5);

    habits.parameters.clear();

    expect(analytics.totalActiveHabits.value, 0);
    expect(analytics.overallCompletionRate.value, 0);
    expect(analytics.overallCurrentStreak.value, 0);
    expect(analytics.heatmapData, isEmpty);
    expect(analytics.topHabits, isEmpty);
  });

  test('publishes the heatmap once per recompute', () async {
    await load([_habit('a')], _history(['a'], 5));
    var notifications = 0;
    final sub = analytics.heatmapData.listen((_) => notifications++);
    addTearDown(sub.cancel);

    // A single emission, as the Firestore stream produces; assignAll emits twice.
    habits.parameters.value = [_habit('a'), _habit('b')];
    await Future<void>.delayed(Duration.zero);

    expect(notifications, 1);
    expect(analytics.heatmapData, hasLength(365));
  });

  test('ranks habits that share a name separately', () async {
    await load([
      _habit('x', name: 'Read'),
      _habit('y', name: 'Read'),
    ], _history(['x', 'y'], 1));

    expect(analytics.topHabits, ['Read', 'Read']);
  });
}
