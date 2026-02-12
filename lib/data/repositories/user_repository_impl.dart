import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserEntity> createUser(
      String id,
      String email,
      String name,
      ) async {
    final userModel = UserModel(
      id: id,
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(id)
        .set(userModel.toFirestore());

    return userModel.toEntity();
  }

  @override
  Future<UserEntity?> getUser(String id) async {
    final doc = await _firestore
        .collection('users')
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc).toEntity();
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(id)
        .update(data);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _firestore
        .collection('users')
        .doc(id)
        .delete();
  }
}
