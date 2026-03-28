import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_constants.dart';
import '../../domain/entities/entry_entity.dart';
import '../../domain/repositories/entry_repository.dart';
import '../cache/analytics_cache_service.dart';

class EntryRepositoryImpl implements EntryRepository {
  final FirebaseFirestore _firestore;
  final AnalyticsCacheService _cache;

  EntryRepositoryImpl(this._firestore, this._cache);

  CollectionReference<Map<String, dynamic>> _entriesRef(String userId) {
    return _firestore
        .collection(AppConstants.kUsersCollection)
        .doc(userId)
        .collection(AppConstants.kEntriesCollection);
  }

  @override
  Future<List<EntryEntity>> getEntriesForDate(
    String userId,
    DateTime date,
  ) async {
    try {
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
          parameterId:
              data['parameterId'] as String? ?? _parameterIdFromEntryId(doc.id),
          date: (data['date'] as Timestamp).toDate(),
          value: data['value'],
          notes: data['notes'] as String?,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw AppException(ServerFailure(e.message ?? 'Failed to load entries.'));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to load entries.'));
    }
  }

  @override
  Future<Map<DateTime, List<EntryEntity>>> getEntriesForLastNDays(
    String userId,
    int days,
  ) async {
    final cached = _cache.load();

    if (cached.isNotEmpty) {
      _refreshFromFirestore(userId, days);
      return cached;
    }

    final fetchStarted = DateTime.now();
    final fresh = await _fetchFromFirestore(userId, days);
    _cache.saveIfFresh(fresh, fetchStarted);
    return fresh;
  }

  Future<Map<DateTime, List<EntryEntity>>> _fetchFromFirestore(
    String userId,
    int days,
  ) async {
    try {
      final Map<DateTime, List<EntryEntity>> result = {};
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection(AppConstants.kUsersCollection)
          .doc(userId)
          .collection(AppConstants.kEntriesCollection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawDate = (data['date'] as Timestamp).toDate();
        final normalized = DateTime(rawDate.year, rawDate.month, rawDate.day);

        final entry = EntryEntity(
          id: doc.id,
          userId: userId,
          parameterId:
              data['parameterId'] as String? ?? _parameterIdFromEntryId(doc.id),
          date: normalized,
          value: data['value'],
          notes: data['notes'] as String?,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );

        result.putIfAbsent(normalized, () => []);
        result[normalized]!.add(entry);
      }

      return result;
    } on FirebaseException catch (e) {
      throw AppException(
        ServerFailure(e.message ?? 'Failed to fetch analytics data.'),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        const ServerFailure('Failed to fetch analytics data.'),
      );
    }
  }

  void _refreshFromFirestore(String userId, int days) {
    final fetchStarted = DateTime.now();
    _fetchFromFirestore(userId, days)
        .then((fresh) => _cache.saveIfFresh(fresh, fetchStarted))
        .catchError((_) {});
  }
  String _parameterIdFromEntryId(String entryId) {
    const suffixLen = 24;
    if (entryId.length > suffixLen) {
      return entryId.substring(0, entryId.length - suffixLen);
    }
    return entryId; 
  }

  @override
  Future<void> saveEntry(EntryEntity entry) async {
    try {
      await _entriesRef(entry.userId).doc(entry.id).set({
        'parameterId': entry.parameterId,
        'date': Timestamp.fromDate(entry.date),
        'value': entry.value,
        'notes': entry.notes,
        'createdAt': Timestamp.fromDate(entry.createdAt),
      });
    } on FirebaseException catch (e) {
      throw AppException(ServerFailure(e.message ?? 'Failed to save entry.'));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to save entry.'));
    }
  }

  @override
  Future<void> updateEntry(
    String userId,
    DateTime date,
    String parameterId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final entryId =
          '$parameterId-${DateTime(date.year, date.month, date.day).toIso8601String()}';
      await _entriesRef(userId).doc(entryId).update(updates);
    } on FirebaseException catch (e) {
      throw AppException(ServerFailure(e.message ?? 'Failed to update entry.'));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to update entry.'));
    }
  }

  @override
  Future<void> deleteEntry(
    String userId,
    DateTime date,
    String parameterId,
  ) async {
    try {
      final entryId =
          '$parameterId-${DateTime(date.year, date.month, date.day).toIso8601String()}';
      await _entriesRef(userId).doc(entryId).delete();
    } on FirebaseException catch (e) {
      throw AppException(ServerFailure(e.message ?? 'Failed to delete entry.'));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to delete entry.'));
    }
  }

  @override
  Future<void> deleteAllEntriesForParameter(
    String userId,
    String parameterId,
  ) async {
    try {
      final ref = _entriesRef(userId);

      // Query 1: entries saved with the 'parameterId' field (current format)
      final byField = await ref
          .where('parameterId', isEqualTo: parameterId)
          .get();

      // Query 2: entries whose doc ID starts with '$parameterId-'
      // (legacy entries saved without the 'parameterId' field, or as a safety net)
      // Firestore range on __name__ is effectively a prefix scan.
      final byDocId = await ref
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: '$parameterId-')
          .where(FieldPath.documentId, isLessThan: '$parameterId.')
          .get();

      // Merge and de-duplicate by doc id
      final seen = <String>{};
      final allDocs = [
        ...byField.docs,
        ...byDocId.docs,
      ].where((doc) => seen.add(doc.id)).toList();

      // Batch-delete in chunks of 500 (Firestore limit)
      const batchSize = 500;
      for (int i = 0; i < allDocs.length; i += batchSize) {
        final batch = _firestore.batch();
        final chunk = allDocs.sublist(
          i,
          (i + batchSize).clamp(0, allDocs.length),
        );
        for (final doc in chunk) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Evict from local Hive cache (clears entire cache)
      _cache.evictParameter(parameterId);
    } on FirebaseException catch (e) {
      throw AppException(
        ServerFailure(e.message ?? 'Failed to delete habit entries.'),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        const ServerFailure('Failed to delete habit entries.'),
      );
    }
  }
}
