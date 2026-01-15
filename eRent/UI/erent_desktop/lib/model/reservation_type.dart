import 'package:json_annotation/json_annotation.dart';

part 'reservation_type.g.dart';

@JsonSerializable()
class ReservationType {
  final int id;
  final String name;
  final double price;

  ReservationType({
    this.id = 0,
    this.name = '',
    this.price = 0.0,
  });

  factory ReservationType.fromJson(Map<String, dynamic> json) => _$ReservationTypeFromJson(json);
  Map<String, dynamic> toJson() => _$ReservationTypeToJson(this);
}

