import 'package:json_annotation/json_annotation.dart';
import 'package:erent_landlord_desktop/model/analytics.dart';

part 'landlord_analytics.g.dart';

@JsonSerializable()
class LandlordAnalytics {
  final double totalRevenue;
  final double monthlyRevenue;
  final double averageRentPrice;
  final List<RevenueByPropertyType> revenueByPropertyType;
  final List<RevenueByCity> revenueByCity;
  final List<MonthlyRevenueData> monthlyRevenueTrend;
  final int totalRents;
  final int activeRents;
  final int pendingRents;
  final int paidRents;
  final int cancelledRents;
  final int rejectedRents;
  final int acceptedRents;
  final int dailyRentals;
  final int monthlyRentals;
  final double averageRentalDuration;
  final double occupancyRate;
  final int totalProperties;
  final int activeProperties;
  final int inactiveProperties;
  final List<PropertyCountByType> propertiesByType;
  final List<PropertyCountByCity> propertiesByCity;
  final List<AveragePriceByType> averagePriceByPropertyType;
  final int totalReviews;
  final double averageRating;
  final int rating5Count;
  final int rating4Count;
  final int rating3Count;
  final int rating2Count;
  final int rating1Count;
  final List<MonthlyPropertyGrowth> monthlyPropertyGrowth;
  final List<MonthlyRentGrowth> monthlyRentGrowth;

  const LandlordAnalytics({
    this.totalRevenue = 0.0,
    this.monthlyRevenue = 0.0,
    this.averageRentPrice = 0.0,
    this.revenueByPropertyType = const [],
    this.revenueByCity = const [],
    this.monthlyRevenueTrend = const [],
    this.totalRents = 0,
    this.activeRents = 0,
    this.pendingRents = 0,
    this.paidRents = 0,
    this.cancelledRents = 0,
    this.rejectedRents = 0,
    this.acceptedRents = 0,
    this.dailyRentals = 0,
    this.monthlyRentals = 0,
    this.averageRentalDuration = 0.0,
    this.occupancyRate = 0.0,
    this.totalProperties = 0,
    this.activeProperties = 0,
    this.inactiveProperties = 0,
    this.propertiesByType = const [],
    this.propertiesByCity = const [],
    this.averagePriceByPropertyType = const [],
    this.totalReviews = 0,
    this.averageRating = 0.0,
    this.rating5Count = 0,
    this.rating4Count = 0,
    this.rating3Count = 0,
    this.rating2Count = 0,
    this.rating1Count = 0,
    this.monthlyPropertyGrowth = const [],
    this.monthlyRentGrowth = const [],
  });

  factory LandlordAnalytics.fromJson(Map<String, dynamic> json) => _$LandlordAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$LandlordAnalyticsToJson(this);
}

