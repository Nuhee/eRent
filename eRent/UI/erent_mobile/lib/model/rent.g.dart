// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rent _$RentFromJson(Map<String, dynamic> json) => Rent(
  id: (json['id'] as num?)?.toInt() ?? 0,
  propertyId: (json['propertyId'] as num?)?.toInt() ?? 0,
  propertyTitle: json['propertyTitle'] as String? ?? '',
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userName: json['userName'] as String? ?? '',
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  isDailyRental: json['isDailyRental'] as bool? ?? false,
  totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
  rentStatusId: (json['rentStatusId'] as num?)?.toInt() ?? 0,
  rentStatusName: json['rentStatusName'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RentToJson(Rent instance) => <String, dynamic>{
  'id': instance.id,
  'propertyId': instance.propertyId,
  'propertyTitle': instance.propertyTitle,
  'userId': instance.userId,
  'userName': instance.userName,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'isDailyRental': instance.isDailyRental,
  'totalPrice': instance.totalPrice,
  'rentStatusId': instance.rentStatusId,
  'rentStatusName': instance.rentStatusName,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
