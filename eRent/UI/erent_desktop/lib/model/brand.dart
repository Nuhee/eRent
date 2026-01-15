import 'package:json_annotation/json_annotation.dart';

part 'brand.g.dart';

@JsonSerializable()
class Brand {
  final int id;
  final String name;
  final String? logo; // Will be base64 string from backend byte[]
  final bool isActive;
  final DateTime? createdAt;

  Brand({
    this.id = 0,
    this.name = '',
    this.logo,
    this.isActive = true,
    this.createdAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) =>
      _$BrandFromJson(json);
  Map<String, dynamic> toJson() => _$BrandToJson(this);
}

