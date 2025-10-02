enum ParameterType {
  checklist,
  scale,
  value,
  optionSelector,
}

class ParameterEntity {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final ParameterType type;
  final int order;
  final bool isActive;
  final int? minValue;
  final int? maxValue;
  final List<String>? checklistItems;
  final List<String>? options;
  final String? unit;
  final String? valueType;
  final String? icon;
  final String? color;

  ParameterEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.type,
    required this.order,
    this.isActive = true,
    this.minValue,
    this.maxValue,
    this.checklistItems,
    this.options,
    this.unit,
    this.valueType,
    this.icon,
    this.color,
  });
}