import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_constants.dart';
import '../../domain/repositories/streak_repository.dart';

class StreakRepositoryImpl implements StreakRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _streaks(String userId) {
    return _firestore
        .collection(AppConstants.kUsersCollection)
        .doc(userId)
        .collection(AppConstants.kStreaksCollection);
  }

  @override
  Future<void> saveStreak(
    String userId,
    String parameterId,
    int current,
    int best,
    DateTime? lastCompletedDate,
  ) async {
    try {
      await _streaks(userId).doc(parameterId).set({
        'currentStreak': current,
        'bestStreak': best,
        'lastCompletedDate': lastCompletedDate == null
            ? null
            : Timestamp.fromDate(lastCompletedDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw AppException(ServerFailure(e.message ?? 'Failed to save streak.'));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to save streak.'));
    }
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAllStreaks(String userId) async {
    try {
      final snapshot = await _streaks(userId).get();
      final Map<String, Map<String, dynamic>> result = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        // Keep Firestore types out of the domain layer.
        final last = data['lastCompletedDate'];
        result[doc.id] = {
          ...data,
          'lastCompletedDate': last is Timestamp ? last.toDate() : null,
        };
      }
      return result;
    } on FirebaseException catch (e) {
      throw AppException(ServerFailure(e.message ?? 'Failed to load streaks.'));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to load streaks.'));
    }
  }
}