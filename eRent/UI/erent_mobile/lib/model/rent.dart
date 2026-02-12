import 'package:json_annotation/json_annotation.dart';

part 'rent.g.dart';

@JsonSerializable()
class Rent {
  final int id;
  final int propertyId;
  final String propertyTitle;
  final int userId;
  final String userName;
  final DateTime startDate;
  final DateTime endDate;
  final bool isDailyRental;
  final double totalPrice;
  final int rentStatusId;
  final String rentStatusName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Rent({
    this.id = 0,
    this.propertyId = 0,
    this.propertyTitle = '',
    this.userId = 0,
    this.userName = '',
    required this.startDate,
    required this.endDate,
    this.isDailyRental = false,
    this.totalPrice = 0.0,
    this.rentStatusId = 0,
    this.rentStatusName = '',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Rent.fromJson(Map<String, dynamic> json) => _$RentFromJson(json);
  Map<String, dynamic> toJson() => _$RentToJson(this);
}
