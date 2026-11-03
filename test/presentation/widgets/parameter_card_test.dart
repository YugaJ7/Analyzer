import 'dart:io';

import 'package:analyzer/data/cache/streak_cache_service.dart';
import 'package:analyzer/data/models/parameter_model.dart';
import 'package:analyzer/domain/entities/entry_entity.dart';
import 'package:analyzer/domain/entities/parameter_entity.dart';
import 'package:analyzer/domain/repositories/entry_repository.dart';
import 'package:analyzer/domain/repositories/streak_repository.dart';
import 'package:analyzer/domain/usecases/entry_usecases.dart';
import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/controllers/streak_controller.dart';
import 'package:analyzer/presentation/screens/home/widgets/parameter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class _FakeEntryRepository implements EntryRepository {
  @override
  Future<List<EntryEntity>> getEntriesForDate(String u, DateTime d) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStreakRepository implements StreakRepository {
  @override
  Future<Map<String, Map<String, dynamic>>> getAllStreaks(String u) async => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _today = DateTime(2026, 6, 15);

ParameterModel _habit(String id, ParameterType type, {List<String>? options}) =>
    ParameterModel(
      id: id,
      userId: 'uid-1',
      createdAt: DateTime(2026),
      name: id,
      type: type,
      order: 0,
      options: options,
    );

EntryEntity _entry(String id, dynamic value) => EntryEntity(
  id: '$id-entry',
  userId: 'uid-1',
  parameterId: id,
  date: _today,
  value: value,
  createdAt: _today,
);

void main() {
  late Directory hiveDir;
  late EntryController entries;

  setUp(() async {
    Get.testMode = true;
    hiveDir = await Directory.systemTemp.createTemp('parameter_card_test');
    Hive.init(hiveDir.path);

    final entryRepo = _FakeEntryRepository();
    Get.put(
      StreakController(
        streakRepository: _FakeStreakRepository(),
        streakCache: StreakCacheService(await Hive.openBox<dynamic>('s')),
        getEntriesForLastNDays: GetEntriesForLastNDays(entryRepo),
        today: () => _today,
        userId: () => 'uid-1',
      ),
    );
    entries = Get.put(
      EntryController(
        getEntriesForDate: GetEntriesForDate(entryRepo),
        saveEntry: SaveEntry(entryRepo),
        updateEntry: UpdateEntry(entryRepo),
        deleteEntry: DeleteEntry(entryRepo),
        today: () => _today,
        userId: () => 'uid-1',
        syncWidget: () async {},
      ),
    );
    await entries.loadEntries();
  });

  tearDown(() async {
    // Deleting runs onClose, which cancels the controller's midnight timer.
    Get.delete<EntryController>(force: true);
    Get.reset();
    await Hive.deleteFromDisk();
    await hiveDir.delete(recursive: true);
  });

  Future<void> pumpCards(WidgetTester tester, List<ParameterModel> habits) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                for (final habit in habits)
                  ParameterEntryCard(key: ValueKey(habit.id), param: habit),
              ],
            ),
          ),
        ),
      );

  testWidgets('rebuilds only the card whose entry changed', (tester) async {
    await pumpCards(tester, [
      _habit('a', ParameterType.checklist),
      _habit('b', ParameterType.checklist),
    ]);

    final rebuilt = <Key?>[];
    widgets.debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is ParameterEntryCard) rebuilt.add(element.widget.key);
    };
    addTearDown(() => widgets.debugOnRebuildDirtyWidget = null);

    entries.selectedDateEntries['b'] = _entry('b', true);
    await tester.pump();

    expect(rebuilt, [const ValueKey('b')]);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('reflects a switch between options', (tester) async {
    await pumpCards(tester, [
      _habit('mood', ParameterType.optionSelector, options: ['Good', 'Bad']),
    ]);
    entries.selectedDateEntries['mood'] = _entry('mood', 'Good');
    await tester.pump();

    entries.selectedDateEntries['mood'] = _entry('mood', 'Bad');
    await tester.pump();

    final bad = tester.widget<Text>(find.text('Bad'));
    final good = tester.widget<Text>(find.text('Good'));
    expect(bad.style!.color, Colors.white);
    expect(good.style!.color, isNot(Colors.white));
  });
}
