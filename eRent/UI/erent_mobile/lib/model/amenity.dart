import 'package:json_annotation/json_annotation.dart';

part 'amenity.g.dart';

@JsonSerializable()
class Amenity {
  final int id;
  final String name;
  final bool isActive;

  const Amenity({
    this.id = 0,
    this.name = '',
    this.isActive = true,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) => _$AmenityFromJson(json);
  Map<String, dynamic> toJson() => _$AmenityToJson(this);
}
