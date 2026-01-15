// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_spot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingSpot _$ParkingSpotFromJson(Map<String, dynamic> json) => ParkingSpot(
  id: (json['id'] as num?)?.toInt() ?? 0,
  parkingNumber: json['parkingNumber'] as String? ?? '',
  parkingSpotTypeId: (json['parkingSpotTypeId'] as num?)?.toInt() ?? 0,
  parkingSpotTypeName: json['parkingSpotTypeName'] as String? ?? '',
  parkingZoneId: (json['parkingZoneId'] as num?)?.toInt() ?? 0,
  parkingZoneName: json['parkingZoneName'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ParkingSpotToJson(ParkingSpot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parkingNumber': instance.parkingNumber,
      'parkingSpotTypeId': instance.parkingSpotTypeId,
      'parkingSpotTypeName': instance.parkingSpotTypeName,
      'parkingZoneId': instance.parkingZoneId,
      'parkingZoneName': instance.parkingZoneName,
      'isActive': instance.isActive,
    };
