import 'package:json_annotation/json_annotation.dart';

part 'property_type.g.dart';

@JsonSerializable()
class PropertyType {
  final int id;
  final String name;
  final bool isActive;

  const PropertyType({
    this.id = 0,
    this.name = '',
    this.isActive = true,
  });

  factory PropertyType.fromJson(Map<String, dynamic> json) => _$PropertyTypeFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyTypeToJson(this);
}
