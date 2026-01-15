// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: (json['id'] as num?)?.toInt() ?? 0,
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  reservationId: (json['reservationId'] as num?)?.toInt() ?? 0,
  rating: (json['rating'] as num?)?.toInt() ?? 0,
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  userFullName: json['userFullName'] as String?,
  userEmail: json['userEmail'] as String?,
  userPicture: json['userPicture'] as String?,
  carBrandName: json['carBrandName'] as String?,
  carModel: json['carModel'] as String?,
  carLicensePlate: json['carLicensePlate'] as String?,
  parkingSpotNumber: json['parkingSpotNumber'] as String?,
  reservationTypeName: json['reservationTypeName'] as String?,
  reservationStartDate: json['reservationStartDate'] == null
      ? null
      : DateTime.parse(json['reservationStartDate'] as String),
  reservationEndDate: json['reservationEndDate'] == null
      ? null
      : DateTime.parse(json['reservationEndDate'] as String),
  reservationFinalPrice: (json['reservationFinalPrice'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'reservationId': instance.reservationId,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'userFullName': instance.userFullName,
  'userEmail': instance.userEmail,
  'userPicture': instance.userPicture,
  'carBrandName': instance.carBrandName,
  'carModel': instance.carModel,
  'carLicensePlate': instance.carLicensePlate,
  'parkingSpotNumber': instance.parkingSpotNumber,
  'reservationTypeName': instance.reservationTypeName,
  'reservationStartDate': instance.reservationStartDate?.toIso8601String(),
  'reservationEndDate': instance.reservationEndDate?.toIso8601String(),
  'reservationFinalPrice': instance.reservationFinalPrice,
};
