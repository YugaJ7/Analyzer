import '../entities/parameter_entity.dart';
import '../repositories/parameter_repository.dart';

class GetParameters {
  final ParameterRepository repository;
  GetParameters(this.repository);

  Future<List<ParameterEntity>> call(String userId) {
    return repository.getParameters(userId);
  }
}

class AddParameter {
  final ParameterRepository repository;
  AddParameter(this.repository);

  Future<ParameterEntity> call(ParameterEntity parameter) {
    return repository.addParameter(parameter);
  }
}

class UpdateParameter {
  final ParameterRepository repository;
  UpdateParameter(this.repository);

  Future<void> call(
      String userId,
      String id,
      Map<String, dynamic> updates,
      ) {
    return repository.updateParameter(userId, id, updates);
  }
}

class DeleteParameter {
  final ParameterRepository repository;
  DeleteParameter(this.repository);

  Future<void> call(String userId, String id) {
    return repository.deleteParameter(userId, id);
  }
}
