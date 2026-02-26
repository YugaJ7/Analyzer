import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/entry_entity.dart';
import '../../domain/repositories/entry_repository.dart';

class EntryRepositoryImpl implements EntryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _entries(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('entries');
  }

  @override
  Future<List<EntryEntity>> getEntriesForDate(
      String userId,
      DateTime date,
  ) async {
    final normalized = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final snapshot = await _entries(userId)
        .where('date',
            isEqualTo: Timestamp.fromDate(normalized))
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
        createdAt:
            (data['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<void> saveEntry(EntryEntity entry) async {
    await _entries(entry.userId).doc(entry.id).set({
      'parameterId': entry.parameterId,
      'date': Timestamp.fromDate(entry.date),
      'value': entry.value,
      'notes': entry.notes,
      'createdAt':
          Timestamp.fromDate(entry.createdAt),
    });
  }

  @override
  Future<void> updateEntry(
    String userId,
    DateTime date,
    String parameterId,
    Map<String, dynamic> updates,
  ) async {
    final snapshot = await _entries(userId)
        .where('parameterId', isEqualTo: parameterId)
        .where('date',
            isEqualTo:
                Timestamp.fromDate(date))
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update(updates);
    }
  }

  @override
  Future<void> deleteEntry(
    String userId,
    DateTime date,
    String parameterId,
  ) async {
    final snapshot = await _entries(userId)
        .where('parameterId', isEqualTo: parameterId)
        .where('date',
            isEqualTo:
                Timestamp.fromDate(date))
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<Map<DateTime, List<EntryEntity>>>
      getEntriesForLastNDays(
    String userId,
    int days,
  ) async {
    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days));

    final snapshot = await _entries(userId)
        .where('date',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(startDate))
        .get();

    final Map<DateTime, List<EntryEntity>>
        result = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final date =
          (data['date'] as Timestamp).toDate();

      final normalized = DateTime(
        date.year,
        date.month,
        date.day,
      );

      final entry = EntryEntity(
        id: doc.id,
        userId: userId,
        parameterId: data['parameterId'],
        date: normalized,
        value: data['value'],
        notes: data['notes'],
        createdAt:
            (data['createdAt'] as Timestamp)
                .toDate(),
      );

      result.putIfAbsent(
          normalized, () => []);
      result[normalized]!.add(entry);
    }

    return result;
  }
}