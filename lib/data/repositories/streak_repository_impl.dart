import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/streak_repository.dart';

class StreakRepositoryImpl implements StreakRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _streaks(String userId) {
    return _firestore.collection('users').doc(userId).collection('streaks');
  }

  @override
  Future<void> saveStreak(
    String userId,
    String parameterId,
    int current,
    int best,
  ) async {
    await _streaks(userId).doc(parameterId).set({
      'currentStreak': current,
      'bestStreak': best,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAllStreaks(String userId) async {
    final snapshot = await _streaks(userId).get();

    final Map<String, Map<String, dynamic>> result = {};

    for (final doc in snapshot.docs) {
      result[doc.id] = doc.data();
    }

    return result;
  }
}