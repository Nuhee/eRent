// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyType _$PropertyTypeFromJson(Map<String, dynamic> json) => PropertyType(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$PropertyTypeToJson(PropertyType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isActive': instance.isActive,
    };
