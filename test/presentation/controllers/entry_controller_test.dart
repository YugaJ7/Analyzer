import 'dart:async';

import 'package:analyzer/core/utils/date_utils.dart';
import 'package:analyzer/domain/entities/entry_entity.dart';
import 'package:analyzer/domain/repositories/entry_repository.dart';
import 'package:analyzer/domain/usecases/entry_usecases.dart';
import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Entry source whose per-date loads complete only when the test says so.
class _ControlledEntryRepository implements EntryRepository {
  final pending = <DateTime, Completer<List<EntryEntity>>>{};
  final saved = <EntryEntity>[];

  void complete(DateTime date, List<String> parameterIds) {
    pending.remove(date)!.complete([
      for (final id in parameterIds)
        EntryEntity(
          id: '$id-$date',
          userId: 'uid-1',
          parameterId: id,
          date: date,
          value: true,
          createdAt: date,
        ),
    ]);
  }

  @override
  Future<List<EntryEntity>> getEntriesForDate(String userId, DateTime date) =>
      (pending[date] = Completer<List<EntryEntity>>()).future;

  @override
  Future<void> saveEntry(EntryEntity entry) async => saved.add(entry);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final today = DateTime(2026, 6, 15);
  final dayA = AppDateUtils.addDays(today, -3);
  final dayB = AppDateUtils.addDays(today, -2);

  late DateTime clock;
  late _ControlledEntryRepository repository;
  late EntryController controller;

  setUp(() {
    clock = today;
    repository = _ControlledEntryRepository();
    controller = EntryController(
      getEntriesForDate: GetEntriesForDate(repository),
      saveEntry: SaveEntry(repository),
      updateEntry: UpdateEntry(repository),
      deleteEntry: DeleteEntry(repository),
      today: () => clock,
      userId: () => 'uid-1',
      syncWidget: () async {},
    );
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('loadEntries race', () {
    test(
      'a slow load for a previous date never replaces the current one',
      () async {
        controller.changeSelectedDate(dayA);
        controller.changeSelectedDate(dayB);

        repository.complete(dayB, ['from-b']);
        await settle();
        repository.complete(dayA, ['from-a']);
        await settle();

        expect(controller.selectedDate.value, dayB);
        expect(controller.selectedDateEntries.keys, ['from-b']);
      },
    );

    test(
      'the stale result is still cached for when the user returns',
      () async {
        controller.changeSelectedDate(dayA);
        controller.changeSelectedDate(dayB);
        repository.complete(dayA, ['from-a']);
        repository.complete(dayB, ['from-b']);
        await settle();

        controller.changeSelectedDate(dayA);
        await settle();

        expect(repository.pending, isEmpty);
        expect(controller.selectedDateEntries.keys, ['from-a']);
      },
    );

    test('ignores taps while the screen still shows another date', () async {
      controller.changeSelectedDate(dayA);
      repository.complete(dayA, []);
      await settle();

      controller.changeSelectedDate(dayB);
      await controller.toggleEntry('habit', true, syncWidget: false);

      expect(repository.saved, isEmpty);
      expect(controller.selectedDateEntries, isEmpty);
    });
  });

  group('handleDayChange', () {
    test('moves a today view to the new day after midnight', () async {
      clock = AppDateUtils.addDays(today, 1);

      controller.handleDayChange();
      await settle();

      expect(controller.selectedDate.value, clock);
      expect(repository.pending.keys, [clock]);
    });

    test('keeps a past date the user picked', () {
      controller.changeSelectedDate(dayA);
      clock = AppDateUtils.addDays(today, 1);

      controller.handleDayChange();

      expect(controller.selectedDate.value, dayA);
    });

    test('is a no-op when the day has not changed', () {
      controller.handleDayChange();

      expect(controller.selectedDate.value, today);
      expect(repository.pending, isEmpty);
    });
  });
}
