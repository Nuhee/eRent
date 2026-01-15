// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarColor _$CarColorFromJson(Map<String, dynamic> json) => CarColor(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  hexCode: json['hexCode'] as String? ?? '',
);

Map<String, dynamic> _$CarColorToJson(CarColor instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'hexCode': instance.hexCode,
};
