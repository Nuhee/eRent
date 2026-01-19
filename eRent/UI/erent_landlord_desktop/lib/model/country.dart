import 'package:json_annotation/json_annotation.dart';


part 'country.g.dart';
@JsonSerializable()
class Country {
  final int id;
  final String name;
  final String? code;
  final bool isActive;


  Country({
    this.id = 0,
    this.name = '',
    this.code,
    this.isActive = true,
  });

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);
  Map<String, dynamic> toJson() => _$CountryToJson(this);
}
