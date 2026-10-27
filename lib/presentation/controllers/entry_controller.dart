import 'dart:async';

import 'package:analyzer/core/utils/app_logger.dart';
import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/core/utils/date_utils.dart';
import 'package:analyzer/presentation/services/widget_sync_service.dart';
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
  // Resolved lazily: both are registered after this controller.
  final AnalyticsController Function() _analytics;
  final StreakController Function() _streaks;

  EntryController({
    required this.getEntriesForDate,
    required this.saveEntry,
    required this.updateEntry,
    required this.deleteEntry,
    DateTime Function()? today,
    String Function()? userId,
    Future<void> Function()? syncWidget,
    AnalyticsController Function()? analytics,
    StreakController Function()? streaks,
  }) : _today = today ?? AppDateUtils.today,
       _userId = userId ?? (() => FirebaseAuth.instance.currentUser!.uid),
       _syncWidget = syncWidget ?? WidgetSyncService.syncNow,
       _analytics = analytics ?? Get.find<AnalyticsController>,
       _streaks = streaks ?? Get.find<StreakController>,
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

  /// Applies the change optimistically; if persisting fails, local state is
  /// rolled back and the user is told.
  Future<void> toggleEntry(
    String parameterId,
    dynamic value, {
    String? notes,
    bool syncWidget = true,
  }) async {
    final date = _normalizedSelectedDate();

    // Entries on screen belong to another date until the load lands; acting
    // now would write against the wrong day's state.
    if (_displayedKey != _dateKey(date)) return;

    final previous = selectedDateEntries[parameterId];
    final next = _nextEntry(parameterId, date, previous, value, notes: notes);
    if (previous == null && next == null) return;

    await _setLocalEntry(date, parameterId, next);
    try {
      await _persist(date, parameterId, previous: previous, next: next);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Entry save failed',
        name: 'EntryController',
        error: error,
        stackTrace: stackTrace,
      );
      await _setLocalEntry(date, parameterId, previous);
      _onSaveFailed();
    }

    if (syncWidget && date == _today()) await _syncWidgetNow();
  }

  /// Applies queued home-screen widget taps. Each failed write is rolled back
  /// and the first error rethrown, so the caller keeps the queue for a retry.
  Future<void> applyTodayWidgetActionsOptimistically(
    List<Map<String, dynamic>> actions,
  ) async {
    if (actions.isEmpty) return;

    final date = _normalizedSelectedDate();
    if (date != _today() || _displayedKey != _dateKey(date)) {
      throw StateError('Widget actions require today to be displayed');
    }

    final writes = <Future<void>>[];
    for (final action in actions) {
      final parameterId = action['parameterId'] as String?;
      if (parameterId == null) continue;

      final previous = selectedDateEntries[parameterId];
      final result = _widgetActionResult(parameterId, date, previous, action);
      if (result == null) continue;

      await _setLocalEntry(date, parameterId, result.next);
      writes.add(
        _persist(
          date,
          parameterId,
          previous: previous,
          next: result.next,
        ).catchError((Object error, StackTrace stackTrace) async {
          await _setLocalEntry(date, parameterId, previous);
          Error.throwWithStackTrace(error, stackTrace);
        }),
      );
    }

    // eagerError off: every write settles (and rolls back) before rethrowing.
    await Future.wait(writes);
  }

  /// The entry [value] produces, or null for "no entry". A bool toggles.
  EntryEntity? _nextEntry(
    String parameterId,
    DateTime date,
    EntryEntity? existing,
    dynamic value, {
    String? notes,
  }) {
    if (value is bool) {
      return existing != null
          ? null
          : _newEntry(parameterId, date, true, notes: notes);
    }
    if (value == null) return null;
    return existing?.copyWith(value: value) ??
        _newEntry(parameterId, date, value, notes: notes);
  }

  /// Null when the action changes nothing; otherwise the resulting entry.
  ({EntryEntity? next})? _widgetActionResult(
    String parameterId,
    DateTime date,
    EntryEntity? existing,
    Map<String, dynamic> action,
  ) {
    switch (action['type']) {
      case 'checklist':
        final done = action['done'] == true;
        if ((existing != null) == done) return null;
        return (next: done ? _newEntry(parameterId, date, true) : null);
      case 'optionSelector':
        final value = action['value']?.toString();
        if (value == null) return null;
        // Blank is the widget's "unselect" sentinel.
        if (value.isEmpty) return existing == null ? null : (next: null);
        if (existing?.value?.toString() == value) return null;
        return (
          next:
              existing?.copyWith(value: value) ??
              _newEntry(parameterId, date, value),
        );
      default:
        return null;
    }
  }

  EntryEntity _newEntry(
    String parameterId,
    DateTime date,
    dynamic value, {
    String? notes,
  }) {
    return EntryEntity(
      id: '$parameterId-${date.toIso8601String()}',
      userId: _userId(),
      parameterId: parameterId,
      date: date,
      value: value,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  /// Single point that updates every local view of an entry: the displayed
  /// map (if [date] is on screen), day cache, analytics and streak.
  Future<void> _setLocalEntry(
    DateTime date,
    String parameterId,
    EntryEntity? entry,
  ) async {
    final key = _dateKey(date);
    final dayEntries = _displayedKey == key
        ? selectedDateEntries
        : <String, EntryEntity>{...?_dailyCache[key]};
    final wasCompleted = dayEntries.containsKey(parameterId);

    if (entry == null) {
      dayEntries.remove(parameterId);
    } else {
      dayEntries[parameterId] = entry;
    }
    _dailyCache[key] = Map.of(dayEntries);

    // Value edits don't change completion, so stats are unaffected.
    if (wasCompleted == (entry != null)) return;

    final analytics = _analytics()
      ..updateFromEntryChange(parameterId, date, entry != null);
    final streaks = _streaks();
    if (date == _today()) {
      // mark/unmark are exact inverses and need no loaded history.
      entry != null
          ? streaks.markToday(parameterId)
          : streaks.unmarkToday(parameterId);
    } else if (analytics.history.isNotEmpty) {
      await streaks.recomputeFromHistory(parameterId, analytics.history);
    }
  }

  Future<void> _persist(
    DateTime date,
    String parameterId, {
    required EntryEntity? previous,
    required EntryEntity? next,
  }) {
    final userId = _userId();
    if (next == null) return deleteEntry(userId, date, parameterId);
    if (previous == null) return saveEntry(next);
    return updateEntry(userId, date, parameterId, {'value': next.value});
  }

  void _onSaveFailed() {
    if (Get.testMode) return;
    Get.snackbar(
      AppStrings.saveFailedTitle,
      AppStrings.saveFailedMessage,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void changeSelectedDate(DateTime date) {
    selectedDate.value = AppDateUtils.dateOnly(date);
    loadEntries();
  }
}
