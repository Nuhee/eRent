import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  final int userId;
  final int reservationId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  
  // User details
  final String? userFullName;
  final String? userEmail;
  final String? userPicture;
  
  // Reservation details
  final String? carBrandName;
  final String? carModel;
  final String? carLicensePlate;
  final String? parkingSpotNumber;
  final String? reservationTypeName;
  final DateTime? reservationStartDate;
  final DateTime? reservationEndDate;
  final double? reservationFinalPrice;

  const Review({
    this.id = 0,
    this.userId = 0,
    this.reservationId = 0,
    this.rating = 0,
    this.comment,
    required this.createdAt,
    this.userFullName,
    this.userEmail,
    this.userPicture,
    this.carBrandName,
    this.carModel,
    this.carLicensePlate,
    this.parkingSpotNumber,
    this.reservationTypeName,
    this.reservationStartDate,
    this.reservationEndDate,
    this.reservationFinalPrice,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
