// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reservation _$ReservationFromJson(Map<String, dynamic> json) => Reservation(
  id: (json['id'] as num?)?.toInt() ?? 0,
  carId: (json['carId'] as num?)?.toInt() ?? 0,
  parkingSpotId: (json['parkingSpotId'] as num?)?.toInt() ?? 0,
  reservationTypeId: (json['reservationTypeId'] as num?)?.toInt() ?? 0,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  carModel: json['carModel'] as String?,
  carBrandName: json['carBrandName'] as String?,
  carLicensePlate: json['carLicensePlate'] as String?,
  carColorName: json['carColorName'] as String?,
  carColorHexCode: json['carColorHexCode'] as String?,
  parkingSpotNumber: json['parkingSpotNumber'] as String?,
  reservationTypeName: json['reservationTypeName'] as String?,
  userFullName: json['userFullName'] as String?,
  userPicture: json['userPicture'] as String?,
);

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'carId': instance.carId,
      'parkingSpotId': instance.parkingSpotId,
      'reservationTypeId': instance.reservationTypeId,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'finalPrice': instance.finalPrice,
      'createdAt': instance.createdAt.toIso8601String(),
      'carModel': instance.carModel,
      'carBrandName': instance.carBrandName,
      'carLicensePlate': instance.carLicensePlate,
      'carColorName': instance.carColorName,
      'carColorHexCode': instance.carColorHexCode,
      'parkingSpotNumber': instance.parkingSpotNumber,
      'reservationTypeName': instance.reservationTypeName,
      'userFullName': instance.userFullName,
      'userPicture': instance.userPicture,
    };
