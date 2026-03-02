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

  EntryController({
    required this.getEntriesForDate,
    required this.saveEntry,
    required this.updateEntry,
    required this.deleteEntry,
  });

  final RxMap<String, EntryEntity> selectedDateEntries =
      <String, EntryEntity>{}.obs;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;

  final Map<String, Map<String, EntryEntity>> _dailyCache = {};

  @override
  void onInit() {
    super.onInit();
    loadEntries();
  }

  String _dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> loadEntries() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final normalizedDate = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    final key = _dateKey(normalizedDate);

    if (_dailyCache.containsKey(key)) {
      selectedDateEntries.assignAll(_dailyCache[key]!);
      return;
    }

    isLoading.value = true;

    final entries = await getEntriesForDate(userId, normalizedDate);

    final map = <String, EntryEntity>{};

    for (var entry in entries) {
      map[entry.parameterId] = entry;
    }

    _dailyCache[key] = map;
    selectedDateEntries.assignAll(map);

    isLoading.value = false;
  }

  Future<void> toggleEntry(
    String parameterId,
    dynamic value, {
    String? notes,
  }) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final normalizedDate = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    final existingEntry = selectedDateEntries[parameterId];

    final entryId = "$parameterId-${normalizedDate.toIso8601String()}";

    final analyticsController = Get.find<AnalyticsController>();

    final streakController = Get.find<StreakController>();

    final isToday = normalizedDate == normalizedToday;
    //Removing a entry
    if (existingEntry != null) {
      selectedDateEntries.remove(parameterId);

      // Updating analytics memory first
      analyticsController.updateFromEntryChange(
        parameterId,
        normalizedDate,
        false,
      );

      if (isToday) {
        // Check if yesterday was completed
        final yesterday = normalizedToday.subtract(const Duration(days: 1));

        final yesterdayCompleted =
            analyticsController.history[yesterday]?.any(
              (e) => e.parameterId == parameterId,
            ) ??
            false;
        streakController.unmarkToday(parameterId, yesterdayCompleted);
      } else {
        // Editing past date → full recompute
        await streakController.recomputeFromHistory(
          parameterId,
          analyticsController.history,
        );
      }
      // Firestore async (no await → no UI lag)
      deleteEntry(userId, normalizedDate, parameterId);

      return;
    }

    //Adding a entry
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

    // Updating analytics memory first
    analyticsController.updateFromEntryChange(
      parameterId,
      normalizedDate,
      true,
    );

    if (isToday) {
      final yesterday = normalizedToday.subtract(const Duration(days: 1));

      final yesterdayCompleted =
          analyticsController.history[yesterday]?.any(
            (e) => e.parameterId == parameterId,
          ) ??
          false;

      streakController.markToday(parameterId, yesterdayCompleted);
    } else {
      // Editing past date → full recompute
      await streakController.recomputeFromHistory(
        parameterId,
        analyticsController.history,
      );
    }
    // Firestore async (no await → no UI lag)
    saveEntry(entry);
  }

  void changeSelectedDate(DateTime date) {
    selectedDate.value = date;
    loadEntries();
  }
}
