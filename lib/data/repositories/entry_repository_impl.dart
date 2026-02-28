import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/entry_entity.dart';
import '../../domain/repositories/entry_repository.dart';
import '../cache/analytics_cache_service.dart';

class EntryRepositoryImpl implements EntryRepository {
  final FirebaseFirestore _firestore;
  final AnalyticsCacheService _cache;

  EntryRepositoryImpl(this._firestore, this._cache);

  CollectionReference<Map<String, dynamic>> _entriesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('entries');
  }

  @override
  Future<List<EntryEntity>> getEntriesForDate(
    String userId,
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await _entriesRef(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return EntryEntity(
        id: doc.id,
        userId: userId,
        parameterId: data['parameterId'],
        date: (data['date'] as Timestamp).toDate(),
        value: data['value'],
        notes: data['notes'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<Map<DateTime, List<EntryEntity>>> getEntriesForLastNDays(
    String userId,
    int days,
  ) async {
    final Map<DateTime, List<EntryEntity>> result = {};

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('entries')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final rawDate = (data['date'] as Timestamp).toDate();

      final normalized = DateTime(rawDate.year, rawDate.month, rawDate.day);

      final entry = EntryEntity(
        id: doc.id,
        userId: userId,
        parameterId: data['parameterId'],
        date: normalized,
        value: data['value'],
        notes: data['notes'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );

      result.putIfAbsent(normalized, () => []);
      result[normalized]!.add(entry);
    }

    // Save to Hive for persistence
    _cache.save(result);

    return result;
  }

  @override
  Future<void> saveEntry(EntryEntity entry) async {
    await _entriesRef(entry.userId).doc(entry.id).set({
      'parameterId': entry.parameterId,
      'date': Timestamp.fromDate(entry.date),
      'value': entry.value,
      'notes': entry.notes,
      'createdAt': Timestamp.fromDate(entry.createdAt),
    });
  }

  @override
  Future<void> updateEntry(
    String userId,
    DateTime date,
    String parameterId,
    Map<String, dynamic> updates,
  ) async {
    await _entriesRef(userId).doc(parameterId).update(updates);
  }

  @override
  Future<void> deleteEntry(
    String userId,
    DateTime date,
    String parameterId,
  ) async {
    final entryId =
        "$parameterId-${DateTime(date.year, date.month, date.day).toIso8601String()}";

    await _entriesRef(userId).doc(entryId).delete();
  }
}
