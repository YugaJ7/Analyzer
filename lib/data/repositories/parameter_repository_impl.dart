import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/parameter_entity.dart';
import '../../domain/repositories/parameter_repository.dart';
import '../models/parameter_model.dart';

class ParameterRepositoryImpl implements ParameterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ParameterEntity>> getParameters(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('parameters')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => ParameterModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get parameters: $e');
    }
  }

  @override
  Future<ParameterEntity> addParameter(ParameterEntity parameter) async {
    try {
      final model = ParameterModel.fromEntity(parameter);

      final docRef = await _firestore
          .collection('parameters')
          .add(model.toFirestore());

      await _firestore.collection('users').doc(parameter.userId).update({
        'parameterIds': FieldValue.arrayUnion([docRef.id]),
      });

      return ParameterEntity(
        id: docRef.id,
        userId: parameter.userId,
        name: parameter.name,
        description: parameter.description,
        type: parameter.type,
        order: parameter.order,
        isActive: parameter.isActive,
        minValue: parameter.minValue,
        maxValue: parameter.maxValue,
        checklistItems: parameter.checklistItems,
        options: parameter.options,
        unit: parameter.unit,
        valueType: parameter.valueType,
        icon: parameter.icon,
        color: parameter.color,
      );
    } catch (e) {
      throw Exception('Failed to add parameter: $e');
    }
  }

  @override
  Future<void> updateParameter(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('parameters').doc(id).update(updates);
    } catch (e) {
      throw Exception('Failed to update parameter: $e');
    }
  }

  @override
  Future<void> deleteParameter(String id) async {
    try {
      final doc = await _firestore.collection('parameters').doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'];

        await _firestore.collection('parameters').doc(id).delete();

        await _firestore.collection('users').doc(userId).update({
          'parameterIds': FieldValue.arrayRemove([id]),
        });
      }
    } catch (e) {
      throw Exception('Failed to delete parameter: $e');
    }
  }

  @override
  Stream<List<ParameterEntity>> watchParameters(String userId) {
    return _firestore
        .collection('parameters')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ParameterModel.fromFirestore(doc).toEntity())
              .toList(),
        );
  }
}
