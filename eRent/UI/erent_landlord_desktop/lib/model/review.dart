import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  final int rentId;
  final String propertyTitle;
  final int userId;
  final String userName;
  final int rating;
  final String? comment;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Review({
    this.id = 0,
    this.rentId = 0,
    this.propertyTitle = '',
    this.userId = 0,
    this.userName = '',
    this.rating = 0,
    this.comment,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
