import 'package:json_annotation/json_annotation.dart';

part 'property_image.g.dart';

@JsonSerializable()
class PropertyImage {
  final int id;
  final int propertyId;
  final String propertyTitle;
  final String imageData; // Base64 encoded
  final int? displayOrder;
  final bool isCover;
  final bool isActive;
  final DateTime createdAt;

  const PropertyImage({
    this.id = 0,
    this.propertyId = 0,
    this.propertyTitle = '',
    this.imageData = '',
    this.displayOrder,
    this.isCover = false,
    this.isActive = true,
    required this.createdAt,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) => _$PropertyImageFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyImageToJson(this);
}
