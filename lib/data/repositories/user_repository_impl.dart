import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(AppConstants.kUsersCollection);

  @override
  Future<UserEntity> createUser(String id, String email, String name) async {
    try {
      final userModel = UserModel(
        id: id,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );
      await _usersRef.doc(id).set(userModel.toFirestore());
      return userModel.toEntity();
    } on FirebaseException catch (e) {
      throw AppException(
        ServerFailure(e.message ?? 'Failed to create user profile.'),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to create user profile.'));
    }
  }

  @override
  Future<UserEntity?> getUser(String id) async {
    try {
      final doc = await _usersRef.doc(id).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc).toEntity();
    } on FirebaseException catch (e) {
      throw AppException(
        ServerFailure(e.message ?? 'Failed to fetch user profile.'),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to fetch user profile.'));
    }
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    try {
      await _usersRef.doc(id).update(data);
    } on FirebaseException catch (e) {
      throw AppException(
        ServerFailure(e.message ?? 'Failed to update user profile.'),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to update user profile.'));
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _usersRef.doc(id).delete();
    } on FirebaseException catch (e) {
      throw AppException(ServerFailure(e.message ?? 'Failed to delete user.'));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(const ServerFailure('Failed to delete user.'));
    }
  }
}
