import '../entities/parameter_entity.dart';

abstract class ParameterRepository {
  /// Get all active parameters of a user
  Future<List<ParameterEntity>> getParameters(String userId);

  /// Add parameter under users/{userId}/parameters
  Future<ParameterEntity> addParameter(ParameterEntity parameter);

  /// Update a specific parameter of a user
  Future<void> updateParameter(
    String userId,
    String parameterId,
    Map<String, dynamic> updates,
  );

  /// Delete a specific parameter of a user
  Future<void> deleteParameter(String userId, String parameterId);

  /// Persists display order atomically: `order` = index in [orderedIds].
  Future<void> reorderParameters(String userId, List<String> orderedIds);

  /// Real-time listener for user's parameters
  Stream<List<ParameterEntity>> watchParameters(String userId);
}
