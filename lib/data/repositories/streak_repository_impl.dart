import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/streak_repository.dart';

class StreakRepositoryImpl implements StreakRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      _streaks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('streaks');
  }

  @override
  Future<void> saveStreak(
    String userId,
    String parameterId,
    int current,
    int best,
  ) async {
    await _streaks(userId)
        .doc(parameterId)
        .set({
      'currentStreak': current,
      'bestStreak': best,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Map<String, dynamic>?> getStreak(
    String userId,
    String parameterId,
  ) async {
    final doc = await _streaks(userId)
        .doc(parameterId)
        .get();

    return doc.data();
  }
}