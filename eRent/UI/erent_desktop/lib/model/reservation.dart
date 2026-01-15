import 'package:json_annotation/json_annotation.dart';

part 'reservation.g.dart';

@JsonSerializable()
class Reservation {
  final int id;
  final int carId;
  final int parkingSpotId;
  final int reservationTypeId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double finalPrice;
  final DateTime createdAt;
  
  // Navigation property details
  final String? carModel;
  final String? carBrandName;
  final String? carLicensePlate;
  final String? carColorName;
  final String? carColorHexCode;
  final String? parkingSpotNumber;
  final String? reservationTypeName;
  final String? userFullName;
  final String? userPicture; // Will be base64 string from backend byte[]

  Reservation({
    this.id = 0,
    this.carId = 0,
    this.parkingSpotId = 0,
    this.reservationTypeId = 0,
    this.startDate,
    this.endDate,
    this.finalPrice = 0.0,
    required this.createdAt,
    this.carModel,
    this.carBrandName,
    this.carLicensePlate,
    this.carColorName,
    this.carColorHexCode,
    this.parkingSpotNumber,
    this.reservationTypeName,
    this.userFullName,
    this.userPicture,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);
  Map<String, dynamic> toJson() => _$ReservationToJson(this);
}

