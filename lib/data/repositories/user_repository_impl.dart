import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/firestore_error_messages.dart';
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
        ServerFailure(
          mapFirestoreError(e.code, fallback: 'Failed to create user profile.'),
        ),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw const AppException(ServerFailure('Failed to create user profile.'));
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
        ServerFailure(
          mapFirestoreError(e.code, fallback: 'Failed to fetch user profile.'),
        ),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw const AppException(ServerFailure('Failed to fetch user profile.'));
    }
  }

  @override
  Future<UserEntity> ensureUser(String id, String email, String name) async {
    final DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await _usersRef.doc(id).get();
    } on FirebaseException {
      throw const AppException(ServerFailure('Failed to load user profile.'));
    }

    if (doc.exists) return UserModel.fromFirestore(doc).toEntity();
    return createUser(id, email, name);
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    try {
      // Merge: legacy accounts may have no profile document yet.
      await _usersRef.doc(id).set(data, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw AppException(
        ServerFailure(
          mapFirestoreError(e.code, fallback: 'Failed to update user profile.'),
        ),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw const AppException(ServerFailure('Failed to update user profile.'));
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _usersRef.doc(id).delete();
    } on FirebaseException catch (e) {
      throw AppException(
        ServerFailure(
          mapFirestoreError(e.code, fallback: 'Failed to delete user.'),
        ),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw const AppException(ServerFailure('Failed to delete user.'));
    }
  }
}
