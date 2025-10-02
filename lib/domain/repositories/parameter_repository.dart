import '../entities/parameter_entity.dart';

abstract class ParameterRepository {
  Future<List<ParameterEntity>> getParameters(String userId);
  Future<ParameterEntity> addParameter(ParameterEntity parameter);
  Future<void> updateParameter(String id, Map<String, dynamic> updates);
  Future<void> deleteParameter(String id);
  Stream<List<ParameterEntity>> watchParameters(String userId);
}