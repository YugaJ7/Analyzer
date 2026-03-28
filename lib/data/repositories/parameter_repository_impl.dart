import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_constants.dart';
import '../../domain/entities/parameter_entity.dart';
import '../../domain/repositories/parameter_repository.dart';
import '../models/parameter_model.dart';

class ParameterRepositoryImpl implements ParameterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userParams(String userId) {
    return _firestore
        .collection(AppConstants.kUsersCollection)
        .doc(userId)
        .collection(AppConstants.kParametersCollection);
  }

  @override
  Future<List<ParameterEntity>> getParameters(String userId) async {
    try {
      final snapshot = await _userParams(userId).orderBy('order').get();
      return snapshot.docs
          .map((doc) => ParameterModel.fromFirestore(doc, userId).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw AppException(ServerFailure(e.message ?? 'Failed to load habits.'));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to load habits.'));
    }
  }

  @override
  Future<ParameterEntity> addParameter(ParameterEntity parameter) async {
    try {
      final model = ParameterModel.fromEntity(parameter);
      final docRef = await _userParams(
        parameter.userId,
      ).add(model.toFirestore());
      return parameter.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw AppException(ServerFailure(e.message ?? 'Failed to add habit.'));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to add habit.'));
    }
  }

  @override
  Future<void> updateParameter(
    String userId,
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _userParams(userId).doc(id).update(updates);
    } on FirebaseException catch (e) {
      throw AppException(ServerFailure(e.message ?? 'Failed to update habit.'));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to update habit.'));
    }
  }

  @override
  Future<void> deleteParameter(String userId, String id) async {
    try {
      await _userParams(userId).doc(id).delete();
    } on FirebaseException catch (e) {
      throw AppException(ServerFailure(e.message ?? 'Failed to delete habit.'));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to delete habit.'));
    }
  }

  @override
  Stream<List<ParameterEntity>> watchParameters(String userId) {
    return _userParams(userId)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ParameterModel.fromFirestore(doc, userId).toEntity(),
              )
              .toList(),
        );
  }
}
