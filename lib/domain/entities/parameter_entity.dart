import 'package:equatable/equatable.dart';

enum ParameterType { checklist, value, optionSelector }

class ParameterEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime createdAt;
  final String name;
  final String? description;
  final ParameterType type;
  final int order;
  final bool isActive;
  final List<String>? options;
  final String? unit;
  final String? icon;
  final int? color;

  const ParameterEntity({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.name,
    this.description,
    required this.type,
    required this.order,
    this.isActive = true,
    this.options,
    this.unit,
    this.icon,
    this.color,
  });

  ParameterEntity copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    String? name,
    String? description,
    ParameterType? type,
    int? order,
    bool? isActive,
    List<String>? options,
    String? unit,
    String? valueType,
    String? icon,
    int? color,
  }) {
    return ParameterEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      options: options ?? this.options,
      unit: unit ?? this.unit,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    createdAt,
    name,
    description,
    type,
    order,
    isActive,
    options,
    unit,
    icon,
    color,
  ];
}
