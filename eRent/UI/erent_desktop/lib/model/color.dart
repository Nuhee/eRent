import 'package:json_annotation/json_annotation.dart';

part 'color.g.dart';

@JsonSerializable()
class CarColor {
  final int id;
  final String name;
  final String hexCode;

  CarColor({
    this.id = 0,
    this.name = '',
    this.hexCode = '',
  });

  factory CarColor.fromJson(Map<String, dynamic> json) => _$CarColorFromJson(json);
  Map<String, dynamic> toJson() => _$CarColorToJson(this);
}

