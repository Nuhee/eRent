// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Property _$PropertyFromJson(Map<String, dynamic> json) => Property(
  id: (json['id'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? '',
  description: json['description'] as String?,
  pricePerMonth: (json['pricePerMonth'] as num?)?.toDouble() ?? 0.0,
  pricePerDay: (json['pricePerDay'] as num?)?.toDouble(),
  allowDailyRental: json['allowDailyRental'] as bool? ?? false,
  bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
  bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
  area: (json['area'] as num?)?.toDouble() ?? 0.0,
  propertyTypeId: (json['propertyTypeId'] as num?)?.toInt() ?? 0,
  propertyTypeName: json['propertyTypeName'] as String? ?? '',
  cityId: (json['cityId'] as num?)?.toInt() ?? 0,
  cityName: json['cityName'] as String? ?? '',
  landlordId: (json['landlordId'] as num?)?.toInt() ?? 0,
  landlordName: json['landlordName'] as String? ?? '',
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
  longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  amenities:
      (json['amenities'] as List<dynamic>?)
          ?.map((e) => Amenity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => PropertyImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PropertyToJson(Property instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'pricePerMonth': instance.pricePerMonth,
  'pricePerDay': instance.pricePerDay,
  'allowDailyRental': instance.allowDailyRental,
  'bedrooms': instance.bedrooms,
  'bathrooms': instance.bathrooms,
  'area': instance.area,
  'propertyTypeId': instance.propertyTypeId,
  'propertyTypeName': instance.propertyTypeName,
  'cityId': instance.cityId,
  'cityName': instance.cityName,
  'landlordId': instance.landlordId,
  'landlordName': instance.landlordName,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'amenities': instance.amenities,
  'images': instance.images,
};
