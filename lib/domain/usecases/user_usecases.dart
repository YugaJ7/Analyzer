import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserProfile {
  final UserRepository repository;
  GetUserProfile(this.repository);

  Future<UserEntity?> call(String userId) {
    return repository.getUser(userId);
  }
}

class UpdateUserProfile {
  final UserRepository repository;
  UpdateUserProfile(this.repository);

  Future<void> call(String userId, Map<String, dynamic> data) {
    return repository.updateUser(userId, data);
  }
}

class CreateUserProfile {
  final UserRepository repository;
  CreateUserProfile(this.repository);

  Future<UserEntity> call(String id, String email, String name) {
    return repository.createUser(id, email, name);
  }
}
