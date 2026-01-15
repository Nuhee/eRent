// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_zone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingZone _$ParkingZoneFromJson(Map<String, dynamic> json) => ParkingZone(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ParkingZoneToJson(ParkingZone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isActive': instance.isActive,
    };
