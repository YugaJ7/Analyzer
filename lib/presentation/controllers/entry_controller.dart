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

    final entries =
        await getEntriesForDate(userId, normalizedDate);

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

    final key = _dateKey(normalizedDate);

    if (!_dailyCache.containsKey(key)) {
      _dailyCache[key] = {};
    }

    final existingEntry =
        selectedDateEntries[parameterId];

    if (existingEntry != null &&
        existingEntry.value == value) {
      selectedDateEntries.remove(parameterId);
      _dailyCache[key]!.remove(parameterId);

      deleteEntry(userId, normalizedDate, parameterId);
      return;
    }

    final entry = EntryEntity(
      id: parameterId,
      userId: userId,
      parameterId: parameterId,
      date: normalizedDate,
      value: value,
      notes: notes,
      createdAt: DateTime.now(),
    );

    selectedDateEntries[parameterId] = entry;
    _dailyCache[key]![parameterId] = entry;

    saveEntry(entry);
  }
  
  Future<void> deleteEntryManually(String parameterId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final normalizedDate = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    final key = _dateKey(normalizedDate);

    selectedDateEntries.remove(parameterId);
    _dailyCache[key]?.remove(parameterId);

    await deleteEntry(userId, normalizedDate, parameterId);
  }

  void changeSelectedDate(DateTime date) {
    selectedDate.value = date;
    loadEntries();
  }

  bool hasEntry(String parameterId) {
    return selectedDateEntries.containsKey(parameterId);
  }
}