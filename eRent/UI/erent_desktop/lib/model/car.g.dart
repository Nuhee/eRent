// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Car _$CarFromJson(Map<String, dynamic> json) => Car(
  id: (json['id'] as num?)?.toInt() ?? 0,
  brandId: (json['brandId'] as num?)?.toInt() ?? 0,
  brandName: json['brandName'] as String? ?? '',
  brandLogo: json['brandLogo'] as String?,
  colorId: (json['colorId'] as num?)?.toInt() ?? 0,
  colorName: json['colorName'] as String? ?? '',
  colorHexCode: json['colorHexCode'] as String? ?? '',
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userFullName: json['userFullName'] as String? ?? '',
  model: json['model'] as String? ?? '',
  licensePlate: json['licensePlate'] as String? ?? '',
  yearOfManufacture: (json['yearOfManufacture'] as num?)?.toInt() ?? 0,
  picture: json['picture'] as String?,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$CarToJson(Car instance) => <String, dynamic>{
  'id': instance.id,
  'brandId': instance.brandId,
  'brandName': instance.brandName,
  'brandLogo': instance.brandLogo,
  'colorId': instance.colorId,
  'colorName': instance.colorName,
  'colorHexCode': instance.colorHexCode,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'model': instance.model,
  'licensePlate': instance.licensePlate,
  'yearOfManufacture': instance.yearOfManufacture,
  'picture': instance.picture,
  'isActive': instance.isActive,
};
