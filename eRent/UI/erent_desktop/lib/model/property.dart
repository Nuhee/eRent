import 'package:json_annotation/json_annotation.dart';
import 'package:erent_desktop/model/amenity.dart';
import 'package:erent_desktop/model/property_image.dart';

part 'property.g.dart';

@JsonSerializable()
class Property {
  final int id;
  final String title;
  final String? description;
  final double pricePerMonth;
  final double? pricePerDay;
  final bool allowDailyRental;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final int propertyTypeId;
  final String propertyTypeName;
  final int cityId;
  final String cityName;
  final int landlordId;
  final String landlordName;
  final String? address;
  final double latitude;
  final double longitude;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Amenity> amenities;
  final List<PropertyImage> images;

  const Property({
    this.id = 0,
    this.title = '',
    this.description,
    this.pricePerMonth = 0.0,
    this.pricePerDay,
    this.allowDailyRental = false,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.area = 0.0,
    this.propertyTypeId = 0,
    this.propertyTypeName = '',
    this.cityId = 0,
    this.cityName = '',
    this.landlordId = 0,
    this.landlordName = '',
    this.address,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.amenities = const [],
    this.images = const [],
  });

  factory Property.fromJson(Map<String, dynamic> json) => _$PropertyFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyToJson(this);
}
