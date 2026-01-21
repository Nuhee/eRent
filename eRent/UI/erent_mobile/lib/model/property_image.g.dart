// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyImage _$PropertyImageFromJson(Map<String, dynamic> json) =>
    PropertyImage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      propertyId: (json['propertyId'] as num?)?.toInt() ?? 0,
      propertyTitle: json['propertyTitle'] as String? ?? '',
      imageData: json['imageData'] as String? ?? '',
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
      isCover: json['isCover'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PropertyImageToJson(PropertyImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'propertyId': instance.propertyId,
      'propertyTitle': instance.propertyTitle,
      'imageData': instance.imageData,
      'displayOrder': instance.displayOrder,
      'isCover': instance.isCover,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
