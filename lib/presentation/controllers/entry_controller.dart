import 'dart:async';

import 'package:analyzer/core/utils/date_utils.dart';
import 'package:analyzer/data/services/widget_sync_service.dart';
import 'package:analyzer/presentation/controllers/analytics_controller.dart';
import 'package:analyzer/presentation/controllers/streak_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/entry_entity.dart';
import '../../domain/usecases/entry_usecases.dart';

class EntryController extends GetxController {
  final GetEntriesForDate getEntriesForDate;
  final SaveEntry saveEntry;
  final UpdateEntry updateEntry;
  final DeleteEntry deleteEntry;

  final DateTime Function() _today;
  final String Function() _userId;
  final Future<void> Function() _syncWidget;

  EntryController({
    required this.getEntriesForDate,
    required this.saveEntry,
    required this.updateEntry,
    required this.deleteEntry,
    DateTime Function()? today,
    String Function()? userId,
    Future<void> Function()? syncWidget,
  }) : _today = today ?? AppDateUtils.today,
       _userId = userId ?? (() => FirebaseAuth.instance.currentUser!.uid),
       _syncWidget = syncWidget ?? WidgetSyncService.syncNow,
       selectedDate = (today ?? AppDateUtils.today)().obs {
    _lastKnownToday = selectedDate.value;
  }

  final RxMap<String, EntryEntity> selectedDateEntries =
      <String, EntryEntity>{}.obs;

  final Rx<DateTime> selectedDate;
  final RxBool isLoading = false.obs;
  final RxBool hasLoadedEntries = false.obs;

  final Map<String, Map<String, EntryEntity>> _dailyCache = {};
  Future<void>? _activeLoadFuture;
  String? _activeLoadKey;

  /// Date key of the entries currently in [selectedDateEntries]; lags
  /// [selectedDate] while a load is in flight.
  String? _displayedKey;

  late DateTime _lastKnownToday;
  Timer? _midnightTimer;

  @override
  void onInit() {
    super.onInit();
    _scheduleMidnightRollover();
    loadEntries();
  }

  @override
  void onClose() {
    _midnightTimer?.cancel();
    super.onClose();
  }

  /// Moves a "today" view to the new day once the date changes. Safe to call
  /// at any time (e.g. on app resume); a past date the user picked is kept.
  void handleDayChange() {
    final today = _today();
    if (today == _lastKnownToday) return;

    final wasViewingToday = _normalizedSelectedDate() == _lastKnownToday;
    _lastKnownToday = today;
    if (_midnightTimer != null) _scheduleMidnightRollover();
    if (wasViewingToday) changeSelectedDate(today);
  }

  void _scheduleMidnightRollover() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    // Small buffer so the callback can't fire a hair before midnight.
    final untilMidnight =
        AppDateUtils.addDays(now, 1).difference(now) +
        const Duration(seconds: 1);
    _midnightTimer = Timer(untilMidnight, handleDayChange);
  }

  String _dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  DateTime _normalizedSelectedDate() =>
      AppDateUtils.dateOnly(selectedDate.value);

  Future<void> _syncWidgetNow() => _syncWidget();

  void _showEntries(String key, Map<String, EntryEntity> entries) {
    selectedDateEntries.assignAll(entries);
    _displayedKey = key;
    hasLoadedEntries.value = true;
  }

  void _updateDailyCacheForSelectedDate() {
    final key = _dateKey(_normalizedSelectedDate());
    _dailyCache[key] = Map<String, EntryEntity>.from(selectedDateEntries);
  }

  Future<void> loadEntries({
    bool forceRefresh = false,
    bool syncWidget = true,
  }) async {
    final userId = _userId();
    final normalizedDate = _normalizedSelectedDate();
    final key = _dateKey(normalizedDate);
    final shouldSyncWidget = syncWidget && normalizedDate == _today();

    if (_activeLoadFuture != null && _activeLoadKey == key) {
      await _activeLoadFuture;
      return;
    }

    if (!forceRefresh && _dailyCache.containsKey(key)) {
      _showEntries(key, _dailyCache[key]!);
      if (shouldSyncWidget) {
        await _syncWidgetNow();
      }
      return;
    }

    late final Future<void> loadFuture;
    loadFuture = () async {
      isLoading.value = true;

      try {
        final entries = await getEntriesForDate(userId, normalizedDate);
        final map = {for (final entry in entries) entry.parameterId: entry};

        _dailyCache[key] = map;
        // The user may have moved on to another date while this was loading.
        if (_dateKey(_normalizedSelectedDate()) != key) return;
        _showEntries(key, map);
      } finally {
        // A newer load owns the spinner if one has started since.
        if (identical(_activeLoadFuture, loadFuture)) isLoading.value = false;
      }

      if (shouldSyncWidget) {
        await _syncWidgetNow();
      }
    }();

    _activeLoadKey = key;
    _activeLoadFuture = loadFuture;

    try {
      await loadFuture;
    } finally {
      if (identical(_activeLoadFuture, loadFuture)) {
        _activeLoadFuture = null;
        _activeLoadKey = null;
      }
    }
  }

  Future<void> toggleEntry(
    String parameterId,
    dynamic value, {
    String? notes,
    bool syncWidget = true,
  }) async {
    final userId = _userId();
    final normalizedDate = _normalizedSelectedDate();
    final normalizedToday = _today();

    // Entries on screen belong to another date until the load lands; acting
    // now would write against the wrong day's state.
    if (_displayedKey != _dateKey(normalizedDate)) return;

    final existingEntry = selectedDateEntries[parameterId];

    final entryId = "$parameterId-${normalizedDate.toIso8601String()}";

    final analyticsController = Get.find<AnalyticsController>();

    final streakController = Get.find<StreakController>();

    final isToday = normalizedDate == normalizedToday;

    final bool isBoolean = value is bool;

    // -----------------------------------
    // WIDGET SYNC
    // -----------------------------------
    Future<void> syncWidgetIfToday() async {
      if (!syncWidget || !isToday) return;

      await WidgetSyncService.syncNow();
    }

    // -----------------------------------
    // BOOLEAN / CHECKLIST
    // -----------------------------------
    if (isBoolean) {
      if (existingEntry != null) {
        selectedDateEntries.remove(parameterId);
        _updateDailyCacheForSelectedDate();

        analyticsController.updateFromEntryChange(
          parameterId,
          normalizedDate,
          false,
        );

        if (isToday) {
          streakController.unmarkToday(parameterId);
        } else {
          await streakController.recomputeFromHistory(
            parameterId,
            analyticsController.history,
          );
        }

        await deleteEntry(userId, normalizedDate, parameterId);

        await syncWidgetIfToday();
        return;
      }

      final entry = EntryEntity(
        id: entryId,
        userId: userId,
        parameterId: parameterId,
        date: normalizedDate,
        value: true,
        notes: notes,
        createdAt: DateTime.now(),
      );

      selectedDateEntries[parameterId] = entry;
      _updateDailyCacheForSelectedDate();

      analyticsController.updateFromEntryChange(
        parameterId,
        normalizedDate,
        true,
      );

      if (isToday) {
        streakController.markToday(parameterId);
      } else {
        await streakController.recomputeFromHistory(
          parameterId,
          analyticsController.history,
        );
      }

      await saveEntry(entry);

      await syncWidgetIfToday();
      return;
    }

    // -----------------------------------
    // CLEAR NUMERIC / OPTION
    // -----------------------------------
    if (value == null) {
      if (existingEntry == null) return;

      selectedDateEntries.remove(parameterId);
      _updateDailyCacheForSelectedDate();

      analyticsController.updateFromEntryChange(
        parameterId,
        normalizedDate,
        false,
      );

      if (isToday) {
        streakController.unmarkToday(parameterId);
      } else {
        await streakController.recomputeFromHistory(
          parameterId,
          analyticsController.history,
        );
      }

      await deleteEntry(userId, normalizedDate, parameterId);

      await syncWidgetIfToday();
      return;
    }

    // -----------------------------------
    // UPDATE NUMERIC / OPTION
    // -----------------------------------
    if (existingEntry != null) {
      final updated = existingEntry.copyWith(value: value);

      selectedDateEntries[parameterId] = updated;
      _updateDailyCacheForSelectedDate();

      await updateEntry(userId, normalizedDate, parameterId, {'value': value});

      await syncWidgetIfToday();
      return;
    }

    // -----------------------------------
    // CREATE NUMERIC / OPTION
    // -----------------------------------
    final entry = EntryEntity(
      id: entryId,
      userId: userId,
      parameterId: parameterId,
      date: normalizedDate,
      value: value,
      notes: notes,
      createdAt: DateTime.now(),
    );

    selectedDateEntries[parameterId] = entry;
    _updateDailyCacheForSelectedDate();

    analyticsController.updateFromEntryChange(
      parameterId,
      normalizedDate,
      true,
    );

    if (isToday) {
      streakController.markToday(parameterId);
    } else {
      await streakController.recomputeFromHistory(
        parameterId,
        analyticsController.history,
      );
    }

    await saveEntry(entry);

    await syncWidgetIfToday();
  }

  Future<void> applyWidgetActionsBatch(
    List<Map<String, dynamic>> actions,
  ) async {
    if (actions.isEmpty) {
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final normalizedDate = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    final normalizedToday = _today();
    final isToday = normalizedDate == normalizedToday;

    final analyticsController = Get.find<AnalyticsController>();
    final streakController = Get.find<StreakController>();
    final pendingWrites = <Future<void>>[];

    for (final action in actions) {
      final parameterId = action['parameterId'] as String?;
      final type = action['type'] as String?;
      final done = action['done'] == true;
      final value = action['value'];

      if (parameterId == null || type == null) {
        continue;
      }

      final existingEntry = selectedDateEntries[parameterId];
      final entryId = "$parameterId-${normalizedDate.toIso8601String()}";

      if (type == 'checklist') {
        final isCompleted = existingEntry != null;

        if (isCompleted == done) {
          continue;
        }

        if (done) {
          final entry = EntryEntity(
            id: entryId,
            userId: userId,
            parameterId: parameterId,
            date: normalizedDate,
            value: true,
            createdAt: DateTime.now(),
          );

          selectedDateEntries[parameterId] = entry;
          analyticsController.updateFromEntryChange(
            parameterId,
            normalizedDate,
            true,
          );

          if (isToday) {
            streakController.markToday(parameterId);
          } else {
            await streakController.recomputeFromHistory(
              parameterId,
              analyticsController.history,
            );
          }

          pendingWrites.add(saveEntry(entry));
          continue;
        }

        selectedDateEntries.remove(parameterId);
        analyticsController.updateFromEntryChange(
          parameterId,
          normalizedDate,
          false,
        );

        if (isToday) {
          streakController.unmarkToday(parameterId);
        } else {
          await streakController.recomputeFromHistory(
            parameterId,
            analyticsController.history,
          );
        }

        pendingWrites.add(deleteEntry(userId, normalizedDate, parameterId));
        continue;
      }

      if (type != 'optionSelector') {
        continue;
      }

      final nextValue = value?.toString();
      if (nextValue == null) {
        continue;
      }

      // Blank sentinel from widget means unselect (delete the entry)
      if (nextValue.isEmpty) {
        if (existingEntry == null) continue;

        selectedDateEntries.remove(parameterId);
        analyticsController.updateFromEntryChange(
          parameterId,
          normalizedDate,
          false,
        );

        if (isToday) {
          streakController.unmarkToday(parameterId);
        } else {
          await streakController.recomputeFromHistory(
            parameterId,
            analyticsController.history,
          );
        }

        pendingWrites.add(deleteEntry(userId, normalizedDate, parameterId));
        continue;
      }

      if (existingEntry != null) {
        final currentValue = existingEntry.value?.toString();
        if (currentValue == nextValue) {
          continue;
        }

        selectedDateEntries[parameterId] = existingEntry.copyWith(
          value: nextValue,
        );
        pendingWrites.add(
          updateEntry(userId, normalizedDate, parameterId, {
            'value': nextValue,
          }),
        );
        continue;
      }

      final entry = EntryEntity(
        id: entryId,
        userId: userId,
        parameterId: parameterId,
        date: normalizedDate,
        value: nextValue,
        createdAt: DateTime.now(),
      );

      selectedDateEntries[parameterId] = entry;
      analyticsController.updateFromEntryChange(
        parameterId,
        normalizedDate,
        true,
      );

      if (isToday) {
        streakController.markToday(parameterId);
      } else {
        await streakController.recomputeFromHistory(
          parameterId,
          analyticsController.history,
        );
      }

      pendingWrites.add(saveEntry(entry));
    }

    _updateDailyCacheForSelectedDate();

    if (pendingWrites.isNotEmpty) {
      await Future.wait(pendingWrites);
    }
  }

  Future<void> applyTodayWidgetActionsOptimistically(
    List<Map<String, dynamic>> actions,
  ) async {
    if (actions.isEmpty) {
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final normalizedDate = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    final normalizedToday = _today();

    if (normalizedDate != normalizedToday) {
      await applyWidgetActionsBatch(actions);
      return;
    }

    final analyticsController = Get.find<AnalyticsController>();
    final streakController = Get.find<StreakController>();
    final pendingWrites = <Future<void>>[];

    for (final action in actions) {
      final parameterId = action['parameterId'] as String?;
      final type = action['type'] as String?;
      final done = action['done'] == true;
      final value = action['value'];

      if (parameterId == null || type == null) {
        continue;
      }

      final existingEntry = selectedDateEntries[parameterId];
      final entryId = "$parameterId-${normalizedDate.toIso8601String()}";

      if (type == 'checklist') {
        final isCompleted = existingEntry != null;

        if (isCompleted == done) {
          continue;
        }

        if (done) {
          final entry = EntryEntity(
            id: entryId,
            userId: userId,
            parameterId: parameterId,
            date: normalizedDate,
            value: true,
            createdAt: DateTime.now(),
          );

          selectedDateEntries[parameterId] = entry;
          analyticsController.updateFromEntryChange(
            parameterId,
            normalizedDate,
            true,
          );
          streakController.markToday(parameterId);
          pendingWrites.add(saveEntry(entry));
          continue;
        }

        selectedDateEntries.remove(parameterId);
        analyticsController.updateFromEntryChange(
          parameterId,
          normalizedDate,
          false,
        );
        streakController.unmarkToday(parameterId);
        pendingWrites.add(deleteEntry(userId, normalizedDate, parameterId));
        continue;
      }

      if (type != 'optionSelector') {
        continue;
      }

      final nextValue = value?.toString();
      if (nextValue == null) {
        continue;
      }

      // Blank sentinel from widget means unselect (delete the entry)
      if (nextValue.isEmpty) {
        if (existingEntry == null) continue;

        selectedDateEntries.remove(parameterId);
        analyticsController.updateFromEntryChange(
          parameterId,
          normalizedDate,
          false,
        );
        streakController.unmarkToday(parameterId);
        pendingWrites.add(deleteEntry(userId, normalizedDate, parameterId));
        continue;
      }

      if (existingEntry != null) {
        final currentValue = existingEntry.value?.toString();
        if (currentValue == nextValue) {
          continue;
        }

        selectedDateEntries[parameterId] = existingEntry.copyWith(
          value: nextValue,
        );
        pendingWrites.add(
          updateEntry(userId, normalizedDate, parameterId, {
            'value': nextValue,
          }),
        );
        continue;
      }

      final entry = EntryEntity(
        id: entryId,
        userId: userId,
        parameterId: parameterId,
        date: normalizedDate,
        value: nextValue,
        createdAt: DateTime.now(),
      );

      selectedDateEntries[parameterId] = entry;
      analyticsController.updateFromEntryChange(
        parameterId,
        normalizedDate,
        true,
      );
      streakController.markToday(parameterId);
      pendingWrites.add(saveEntry(entry));
    }

    _updateDailyCacheForSelectedDate();

    if (pendingWrites.isNotEmpty) {
      await Future.wait(pendingWrites);
    }
  }

  void changeSelectedDate(DateTime date) {
    selectedDate.value = AppDateUtils.dateOnly(date);
    loadEntries();
  }
}
