import '../entities/parameter_entity.dart';
import '../repositories/parameter_repository.dart';

class GetParameters {
  final ParameterRepository repository;
  GetParameters(this.repository);
  
  Future<List<ParameterEntity>> call(String userId) async {
    return await repository.getParameters(userId);
  }
}

class AddParameter {
  final ParameterRepository repository;
  AddParameter(this.repository);
  
  Future<ParameterEntity> call(ParameterEntity parameter) async {
    return await repository.addParameter(parameter);
  }
}

class UpdateParameter {
  final ParameterRepository repository;
  UpdateParameter(this.repository);
  
  Future<void> call(String id, Map<String, dynamic> updates) async {
    await repository.updateParameter(id, updates);
  }
}

class DeleteParameter {
  final ParameterRepository repository;
  DeleteParameter(this.repository);
  
  Future<void> call(String id) async {
    await repository.deleteParameter(id);
  }
}