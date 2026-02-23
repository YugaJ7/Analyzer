import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/parameter_entity.dart';

class ParameterModel extends ParameterEntity {
  const ParameterModel({
    required super.id,
    required super.userId,
    required super.createdAt,
    required super.name,
    super.description,
    required super.type,
    required super.order,
    super.isActive,
    super.minValue,
    super.maxValue,
    super.checklistItems,
    super.options,
    super.unit,
    super.valueType,
    super.icon,
    super.color,
  });

  factory ParameterModel.fromEntity(ParameterEntity entity) {
    return ParameterModel(
      id: entity.id,
      userId: entity.userId,
      createdAt: entity.createdAt,
      name: entity.name,
      description: entity.description,
      type: entity.type,
      order: entity.order,
      isActive: entity.isActive,
      minValue: entity.minValue,
      maxValue: entity.maxValue,
      checklistItems: entity.checklistItems,
      options: entity.options,
      unit: entity.unit,
      valueType: entity.valueType,
      icon: entity.icon,
      color: entity.color,
    );
  }

  factory ParameterModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      String userId,
      ) {
    final data = doc.data()!;
    return ParameterModel(
      id: doc.id,
      userId: userId,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      name: data['name'] ?? '',
      description: data['description'],
      type: ParameterType.values.firstWhere(
            (e) => e.name == data['type'],
      ),
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      minValue: data['minValue'],
      maxValue: data['maxValue'],
      checklistItems: data['checklistItems'] != null
          ? List<String>.from(data['checklistItems'])
          : null,
      options: data['options'] != null
          ? List<String>.from(data['options'])
          : null,
      unit: data['unit'],
      valueType: data['valueType'],
      icon: data['icon'],
      color: data['color'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'name': name,
      'description': description,
      'type': type.name,
      'order': order,
      'isActive': isActive,
      'minValue': minValue,
      'maxValue': maxValue,
      'checklistItems': checklistItems,
      'options': options,
      'unit': unit,
      'valueType': valueType,
      'icon': icon,
      'color': color,
    };
  }

  ParameterEntity toEntity() => this;
}
