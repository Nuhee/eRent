import 'package:json_annotation/json_annotation.dart';

part 'gender.g.dart';

@JsonSerializable()
class Gender {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  const Gender({
    this.id = 0,
    this.name = '',
    this.description,
    this.isActive = true,
  });

  factory Gender.fromJson(Map<String, dynamic> json) => _$GenderFromJson(json);
  Map<String, dynamic> toJson() => _$GenderToJson(this);
}
