import 'package:json_annotation/json_annotation.dart';

part 'parking_zone.g.dart';

@JsonSerializable()
class ParkingZone {
  final int id;
  final String name;
  final bool isActive;

  ParkingZone({
    this.id = 0,
    this.name = '',
    this.isActive = true,
  });

  factory ParkingZone.fromJson(Map<String, dynamic> json) =>
      _$ParkingZoneFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingZoneToJson(this);
}

