import 'package:json_annotation/json_annotation.dart';

part 'parking_spot_type.g.dart';

@JsonSerializable()
class ParkingSpotType {
  final int id;
  final String name;
  final String description;
  final double priceMultiplier;
  final bool isActive;

  ParkingSpotType({
    this.id = 0,
    this.name = '',
    this.description = '',
    this.priceMultiplier = 1.0,
    this.isActive = true,
  });

  factory ParkingSpotType.fromJson(Map<String, dynamic> json) =>
      _$ParkingSpotTypeFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingSpotTypeToJson(this);
}

