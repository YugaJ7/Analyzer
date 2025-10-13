import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/parameter_entity.dart';

class ParameterModel extends ParameterEntity {
  ParameterModel({
    required super.id,
    required super.userId,
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

  factory ParameterModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ParameterModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      type: ParameterType.values.firstWhere(
        (e) => e.toString() == 'ParameterType.${data['type']}',
        orElse: () => ParameterType.scale,
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
      'userId': userId,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
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

  ParameterEntity toEntity() {
    return ParameterEntity(
      id: id,
      userId: userId,
      name: name,
      description: description,
      type: type,
      order: order,
      isActive: isActive,
      minValue: minValue,
      maxValue: maxValue,
      checklistItems: checklistItems,
      options: options,
      unit: unit,
      valueType: valueType,
      icon: icon,
      color: color,
    );
  }
}

// Extension for local updates
extension ParameterModelCopy on ParameterModel {
  ParameterModel copyWithFromMap(Map<String, dynamic> updates) {
    return ParameterModel(
      id: updates['id'] ?? id,
      userId: userId,
      name: updates['name'] ?? name,
      description: updates['description'] ?? description,
      type: updates['type'] != null
          ? ParameterType.values.firstWhere(
              (e) => e.toString() == 'ParameterType.${updates['type']}',
              orElse: () => type,
            )
          : type,
      order: updates['order'] ?? order,
      isActive: updates['isActive'] ?? isActive,
      minValue: updates['minValue'] ?? minValue,
      maxValue: updates['maxValue'] ?? maxValue,
      checklistItems: updates['checklistItems'] ?? checklistItems,
      options: updates['options'] ?? options,
      unit: updates['unit'] ?? unit,
      valueType: updates['valueType'] ?? valueType,
      icon: updates['icon'] ?? icon,
      color: updates['color'] ?? color,
    );
  }
}