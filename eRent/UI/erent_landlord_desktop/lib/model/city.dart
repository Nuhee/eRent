import 'package:json_annotation/json_annotation.dart';


part 'city.g.dart';
@JsonSerializable()
class City {
  final int id;
  final String name;
  final int countryId;
  final String countryName;
  final bool isActive;


  City({
    this.id = 0,
    this.name = '',
    this.countryId = 0,
    this.countryName = '',
    this.isActive = true,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
  Map<String, dynamic> toJson() => _$CityToJson(this);
}