import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/parameter_entity.dart';
import '../../domain/repositories/parameter_repository.dart';
import '../models/parameter_model.dart';

class ParameterRepositoryImpl implements ParameterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userParams(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('parameters');
  }

  @override
  Future<List<ParameterEntity>> getParameters(String userId) async {
    final snapshot = await _userParams(userId)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) =>
        ParameterModel.fromFirestore(doc, userId).toEntity())
        .toList();
  }

  @override
  Future<ParameterEntity> addParameter(ParameterEntity parameter) async {
    final model = ParameterModel.fromEntity(parameter);

    final docRef =
    await _userParams(parameter.userId).add(model.toFirestore());

    return parameter.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateParameter(
      String userId,
      String id,
      Map<String, dynamic> updates,
      ) async {
    await _userParams(userId).doc(id).update(updates);
  }

  @override
  Future<void> deleteParameter(String userId, String id) async {
    await _userParams(userId).doc(id).delete();
  }

  @override
  Stream<List<ParameterEntity>> watchParameters(String userId) {
    return _userParams(userId)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) =>
        ParameterModel.fromFirestore(doc, userId).toEntity())
        .toList());
  }
}
