import 'package:json_annotation/json_annotation.dart';

part 'car.g.dart';

@JsonSerializable()
class Car {
  final int id;
  final int brandId;
  final String brandName;
  final String? brandLogo; // Will be base64 string from backend byte[]
  final int colorId;
  final String colorName;
  final String colorHexCode;
  final int userId;
  final String userFullName;
  final String model;
  final String licensePlate;
  final int yearOfManufacture;
  final String? picture; // Will be base64 string from backend byte[]
  final bool isActive;

  Car({
    this.id = 0,
    this.brandId = 0,
    this.brandName = '',
    this.brandLogo,
    this.colorId = 0,
    this.colorName = '',
    this.colorHexCode = '',
    this.userId = 0,
    this.userFullName = '',
    this.model = '',
    this.licensePlate = '',
    this.yearOfManufacture = 0,
    this.picture,
    this.isActive = true,
  });

  factory Car.fromJson(Map<String, dynamic> json) => _$CarFromJson(json);
  Map<String, dynamic> toJson() => _$CarToJson(this);
}

