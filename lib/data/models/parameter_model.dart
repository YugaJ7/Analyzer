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
    super.checklistItems,
    super.options,
    super.unit,
    super.valueType,
    super.icon,
    super.color,
  });

  // Factory constructors 

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
      checklistItems: entity.checklistItems,
      options: entity.options,
      unit: entity.unit,
      valueType: entity.valueType,
      icon: entity.icon,
      color: entity.color,
    );
  }

  factory ParameterModel.fromJson(Map<String, dynamic> json) {
    return ParameterModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      name: json['name'] as String,
      description: json['description'] as String?,
      type: ParameterType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ParameterType.checklist,
      ),
      order: (json['order'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
      checklistItems: (json['checklistItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      unit: json['unit'] as String?,
      valueType: json['valueType'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as int?,
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
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      type: ParameterType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ParameterType.checklist,
      ),
      order: (data['order'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      checklistItems: data['checklistItems'] != null
          ? List<String>.from(data['checklistItems'] as List)
          : null,
      options: data['options'] != null
          ? List<String>.from(data['options'] as List)
          : null,
      unit: data['unit'] as String?,
      valueType: data['valueType'] as String?,
      icon: data['icon'] as String?,
      color: data['color'] as int?,
    );
  }

  // Serialisation 
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
      'description': description,
      'type': type.name,
      'order': order,
      'isActive': isActive,
      'checklistItems': checklistItems,
      'options': options,
      'unit': unit,
      'valueType': valueType,
      'icon': icon,
      'color': color,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'name': name,
      'description': description,
      'type': type.name,
      'order': order,
      'isActive': isActive,
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
